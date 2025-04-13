# Schemat bazy danych 10xDevs Cards

## 1. Tabele

### auth.users
- `id` UUID PRIMARY KEY DEFAULT uuid_generate_v4()
- `email` VARCHAR(255) NOT NULL UNIQUE
- `username` VARCHAR(50) NOT NULL
- `encrypted_password` VARCHAR(255) NOT NULL
- `created_at` TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
- `updated_at` TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

### public.files
- `id` UUID PRIMARY KEY DEFAULT uuid_generate_v4()
- `user_id` UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
- `filename` VARCHAR(255) NOT NULL
- `file_type` VARCHAR(10) NOT NULL CHECK (file_type IN ('pdf', 'txt', 'md'))
- `size_bytes` INTEGER NOT NULL CHECK (size_bytes <= 10485760) -- 10MB limit
- `created_at` TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
- `status` VARCHAR(20) NOT NULL CHECK (status IN ('processing', 'processed', 'error'))
- `error_message` TEXT
- Indeks: `CREATE INDEX idx_files_user_id ON public.files(user_id)`

### public.flashcards
- `id` UUID PRIMARY KEY DEFAULT uuid_generate_v4()
- `user_id` UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
- `front` VARCHAR(300) NOT NULL
- `back` VARCHAR(500) NOT NULL
- `creation_type` VARCHAR(10) NOT NULL CHECK (creation_type IN ('ai', 'manual'))
- `status` VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'accepted', 'rejected'))
- `ai_model` VARCHAR(50) -- NULL dla manual
- `created_at` TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
- `updated_at` TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
- `file_id` UUID REFERENCES public.files(id) ON DELETE SET NULL
- Indeksy:
  - `CREATE INDEX idx_flashcards_user_id ON public.flashcards(user_id)`
  - `CREATE INDEX idx_flashcards_status ON public.flashcards(status)`

### public.review_logs
- `id` UUID PRIMARY KEY DEFAULT uuid_generate_v4()
- `flashcard_id` UUID NOT NULL UNIQUE REFERENCES public.flashcards(id) ON DELETE CASCADE
- `review_date` TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
- `review_status` VARCHAR(20) NOT NULL CHECK (review_status IN ('accepted', 'edited', 'rejected'))
- `rejection_reason` TEXT
- `original_front` VARCHAR(300) -- tylko jeśli edytowano
- `original_back` VARCHAR(500) -- tylko jeśli edytowano
- Indeks: `CREATE INDEX idx_review_logs_flashcard_id ON public.review_logs(flashcard_id)`

### public.generation_stats
- `id` UUID PRIMARY KEY DEFAULT uuid_generate_v4()
- `user_id` UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
- `manual_count` INTEGER DEFAULT 0
- `ai_generated_count` INTEGER DEFAULT 0
- `ai_accepted_count` INTEGER DEFAULT 0
- `ai_rejected_count` INTEGER DEFAULT 0
- `last_updated` TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
- UNIQUE(user_id)
- Indeks: `CREATE INDEX idx_generation_stats_user_id ON public.generation_stats(user_id)`

## 2. Relacje

- auth.users 1:N public.files
- auth.users 1:N public.flashcards
- auth.users 1:1 public.generation_stats
- public.files 1:N public.flashcards
- public.flashcards 1:1 public.review_logs

## 3. Polityki RLS (Row Level Security)

### public.files
```sql
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;

CREATE POLICY files_select ON public.files
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY files_insert ON public.files
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY files_delete ON public.files
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);
```

### public.flashcards
```sql
ALTER TABLE public.flashcards ENABLE ROW LEVEL SECURITY;

CREATE POLICY flashcards_select ON public.flashcards
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY flashcards_insert ON public.flashcards
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY flashcards_update ON public.flashcards
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY flashcards_delete ON public.flashcards
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);
```

### public.review_logs
```sql
ALTER TABLE public.review_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY review_logs_select ON public.review_logs
    FOR SELECT
    TO authenticated
    USING (EXISTS (
        SELECT 1 FROM public.flashcards 
        WHERE flashcards.id = review_logs.flashcard_id 
        AND flashcards.user_id = auth.uid()
    ));

CREATE POLICY review_logs_insert ON public.review_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.flashcards 
        WHERE flashcards.id = review_logs.flashcard_id 
        AND flashcards.user_id = auth.uid()
    ));
```

### public.generation_stats
```sql
ALTER TABLE public.generation_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY generation_stats_select ON public.generation_stats
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY generation_stats_update ON public.generation_stats
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);
```

## 4. Triggery

### Aktualizacja timestampów
```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_flashcards_updated_at
    BEFORE UPDATE ON public.flashcards
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();
```

### Aktualizacja statystyk
```sql
CREATE OR REPLACE FUNCTION update_generation_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.generation_stats (user_id, manual_count, ai_generated_count, ai_accepted_count, ai_rejected_count)
    VALUES (NEW.user_id, 0, 0, 0, 0)
    ON CONFLICT (user_id) DO NOTHING;

    IF TG_OP = 'INSERT' THEN
        IF NEW.creation_type = 'manual' THEN
            UPDATE public.generation_stats
            SET manual_count = manual_count + 1,
                last_updated = CURRENT_TIMESTAMP
            WHERE user_id = NEW.user_id;
        ELSIF NEW.creation_type = 'ai' THEN
            UPDATE public.generation_stats
            SET ai_generated_count = ai_generated_count + 1,
                last_updated = CURRENT_TIMESTAMP
            WHERE user_id = NEW.user_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_stats_on_flashcard_insert
    AFTER INSERT ON public.flashcards
    FOR EACH ROW
    EXECUTE FUNCTION update_generation_stats();

CREATE OR REPLACE FUNCTION update_stats_on_review()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.review_status = 'rejected' THEN
        UPDATE public.generation_stats
        SET ai_rejected_count = ai_rejected_count + 1,
            last_updated = CURRENT_TIMESTAMP
        WHERE user_id = (
            SELECT user_id 
            FROM public.flashcards 
            WHERE id = NEW.flashcard_id
        );
    ELSIF NEW.review_status IN ('accepted', 'edited') THEN
        UPDATE public.generation_stats
        SET ai_accepted_count = ai_accepted_count + 1,
            last_updated = CURRENT_TIMESTAMP
        WHERE user_id = (
            SELECT user_id 
            FROM public.flashcards 
            WHERE id = NEW.flashcard_id
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_stats_on_review_insert
    AFTER INSERT ON public.review_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_stats_on_review();
```