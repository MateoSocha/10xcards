# 10xDevs Cards

## Project Description
10xDevs Cards is a web application designed to streamline the creation of educational flashcards. The application leverages AI to generate flashcards from provided text or uploaded files (PDF, MD, TXT up to 5MB) and also allows users to create flashcards manually. Users can manage their flashcards, review AI-generated flashcards marked as "DRAFT", and access flashcard generation statistics. Additionally, the app provides full user account management including registration, login, password reset, and account deletion.

## Tech Stack
- **Frontend:**
  - Astro 5
  - React 19 (for interactive components)
  - TypeScript 5
  - Tailwind CSS 4
  - Shadcn/ui
- **Backend:**
  - Supabase (for authentication, database, and backend services)
  - AI integration via Openrouter.ai for flashcard generation
- **Other:**
  - Node.js (v22.14.0)

## Getting Started Locally
1. **Install Node.js** (v22.14.0 as specified in the [`.nvmrc`](.nvmrc) file)
2. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd 10xcards
   ```
3. **Install dependencies:**
   ```bash
   npm install
   ```
4. **Run the development server:**
   ```bash
   npm run dev
   ```

## Available Scripts
- **dev**: Starts the Astro development server  
  ```bash
  npm run dev
  ```
- **build**: Builds the project for production  
  ```bash
  npm run build
  ```
- **preview**: Previews the production build  
  ```bash
  npm run preview
  ```
- **astro**: Runs an Astro CLI command  
  ```bash
  npm run astro
  ```
- **lint**: Lints the project files  
  ```bash
  npm run lint
  ```
- **lint:fix**: Lints and fixes issues automatically  
  ```bash
  npm run lint:fix
  ```
- **format**: Formats the project files using Prettier  
  ```bash
  npm run format
  ```

## Project Scope
- **AI-generated Flashcards:**
  - Generate flashcards from pasted text.
  - Generate flashcards from uploaded files (PDF, MD, TXT; max. 5MB).
  - Review and manage AI-generated flashcards which are initially labeled as "DRAFT".
  
- **Manual Flashcard Creation:**
  - Create flashcards through a simple form (front and back text).
  - Edit or delete manually created flashcards.

- **User Account Management:**
  - Registration, login, password reset, and account deletion.
  
- **Flashcard Statistics:**
  - Display counts of manually created and AI-generated flashcards.
  - Track accepted and rejected AI-generated flashcards.

- **Boundaries:**
  - Limited file type support (PDF, MD, TXT only).
  - No advanced spaced repetition algorithm.
  - Web application only (no mobile version).
  - No sharing of flashcard sets between users.

## Project Status
The project is currently under active development, with core functionalities planned as described in the Product Requirements Document (PRD).

## License
This project is licensed under the MIT License.