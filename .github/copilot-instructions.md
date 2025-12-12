# Real Estate Intelligence System - Copilot Instructions

## Project Overview

This is an autonomous 24/7 AI-powered real estate intelligence platform that integrates:
- AI voice systems (ElevenLabs, Google Speech, Twilio)
- Smart contracts and payment processing (Stripe, Coinbase Commerce, crypto exchanges)
- Workflow automation (Gmail API, Google Calendar, SendGrid)
- Web scraping and data collection for distressed properties
- Statistical analysis and behavioral heatmaps
- Google Sheets integration for output

The system runs automated intelligence cycles via GitHub Actions at 6 AM, 12 PM, 6 PM, and 11 PM ET daily.

## Technology Stack

- **Language**: TypeScript with strict mode enabled
- **Runtime**: Node.js >= 20.0.0
- **Package Manager**: npm >= 10.0.0
- **Module System**: CommonJS (`type: "commonjs"` in package.json)
- **Compiler Target**: ES2022
- **AI Services**: OpenAI, Anthropic Claude, Groq, Google Vertex AI
- **Voice**: ElevenLabs, Google Text-to-Speech, Twilio
- **Payments**: Stripe, Coinbase Commerce, Binance, Kraken, Gemini
- **Cloud**: Google Cloud Platform (BigQuery, Storage, Vision, Document AI)
- **Database**: PostgreSQL, Redis, Firebase/Firestore
- **Smart Contracts**: Hardhat, Ethers.js, Solidity
- **Web Scraping**: Puppeteer, Cheerio, Axios
- **Testing**: Jest

## Building, Testing, and Running

### Essential Commands

```bash
# Install dependencies
npm install

# Build TypeScript to JavaScript
npm run build

# Run in development mode
npm run dev

# Start production build
npm start

# Type checking
npm run typecheck

# Linting
npm run lint

# Testing
npm test                    # Run all tests
npm run test:watch         # Watch mode
npm run test:coverage      # With coverage

# Manual intelligence cycle
npm run cron:manual

# Dashboard
npm run dashboard:serve    # Start on http://localhost:4000
```

### Specialized Commands

```bash
# Smart contracts
npm run contracts:compile
npm run contracts:deploy
npm run contracts:test

# Voice system
npm run voice:test

# Workflow automation
npm run workflow:test

# Statistics scraper
npm run scraper:run

# Google Sheets sync
npm run sheets:sync

# Docker
npm run docker:build
npm run docker:up
npm run docker:logs

# Autonomous operations
npm run autonomous:agent
npm run autonomous:scheduler
npm run autonomous:full-cycle
npm run autonomous:diagnose
npm run autonomous:fix
npm run autonomous:heal
```

## Project Structure

```
/
├── src/                        # Main source code
│   ├── ai-voice/              # Voice system (ElevenLabs, Twilio)
│   ├── autonomous/            # Autonomous agent operations
│   ├── config/                # Configuration files
│   ├── crawlers/              # Web scrapers for property data
│   ├── dashboard/             # Live dashboard server
│   ├── data/                  # Data processing
│   ├── integrations/          # External service integrations
│   ├── intelligence/          # AI/ML intelligence modules
│   ├── matching/              # Investor-property matching
│   ├── memory/                # System memory/state management
│   ├── smart-contracts/       # Blockchain and payment integrations
│   ├── statistics/            # Analytics and scraping
│   ├── utils/                 # Utility functions
│   ├── workflow/              # Email/calendar automation
│   ├── orchestrator.ts        # Main system coordinator
│   └── types.ts               # TypeScript type definitions
├── contracts/                  # Solidity smart contracts
├── scripts/                    # Utility scripts (PowerShell, TS)
├── .github/
│   ├── workflows/             # GitHub Actions (CI/CD, cron jobs)
│   ├── instructions/          # Additional instruction files (e.g., snyk_rules)
│   └── copilot-instructions.md # Copilot coding agent instructions
├── config/                     # External configuration
├── data/                       # Data files
├── docs/                       # Documentation
├── logs/                       # Log files
└── reports/                    # Generated reports
```

## Code Style and Conventions

### TypeScript

- **Strict mode enabled**: All TypeScript strict checks are on
- **Target**: ES2022
- **Module system**: CommonJS (use `require()` and `module.exports`)
- **Type definitions**: Define interfaces for all data structures in `src/types.ts` or co-located with modules
- **JSDoc comments**: Use JSDoc for documenting functions and classes
- **Naming conventions**:
  - Interfaces: PascalCase (e.g., `DistressedProperty`, `InvestorProfile`)
  - Variables/functions: camelCase (e.g., `propertyData`, `calculateDistressScore`)
  - Constants: UPPER_SNAKE_CASE (e.g., `MAX_RETRIES`, `API_TIMEOUT`)
  - Files: kebab-case (e.g., `voice-system.ts`, `automation-system.ts`)

### Code Organization

- Keep related functionality together in modules
- Export default objects/classes from modules (e.g., `export default voiceSystem`)
- Use EventEmitter pattern for orchestration and event-driven architecture
- Configuration through environment variables (`.env` file)
- Async/await for asynchronous operations

### Error Handling

- Use try-catch blocks for async operations
- Log errors with context using console.error or Winston logger
- Gracefully handle API failures with retries where appropriate
- Validate environment variables on startup

### API Keys and Secrets

- **NEVER commit secrets**: All API keys go in `.env` (git-ignored)
- Reference documentation in `.env.template` for required keys
- Use `dotenv.config()` at the start of entry points
- Validate required environment variables before use

### Testing

- Test files use `.test.ts` or `.spec.ts` suffix
- Use Jest as the testing framework
- Mock external API calls in tests
- Focus on unit tests for business logic

## Key Subsystems

### 1. AI Voice System (`src/ai-voice/`)
- ElevenLabs for voice synthesis
- Google Speech for recognition
- Twilio for phone call handling
- Test with: `npm run voice:test`

### 2. Smart Contracts & Payments (`src/smart-contracts/`)
- Stripe integration for card payments
- Coinbase Commerce for crypto payments
- Multi-exchange support (Binance, Kraken, Gemini)
- Google Wallet for passes
- Hardhat for smart contract development

### 3. Workflow Automation (`src/workflow/`)
- Gmail API for email automation
- Google Calendar integration
- SendGrid for transactional emails
- Test with: `npm run workflow:test`

### 4. Crawlers & Scrapers (`src/crawlers/`, `src/statistics/`)
- Puppeteer for browser automation
- Cheerio for HTML parsing
- Government data sources
- Social media monitoring

### 5. Orchestrator (`src/orchestrator.ts`)
- Main coordination layer
- Event-driven architecture using EventEmitter
- Manages subsystem lifecycle
- Scheduled via GitHub Actions cron jobs

### 6. Autonomous System (`src/autonomous/`)
- Self-healing capabilities
- Automated diagnostics
- Performance optimization
- Continuous monitoring

## Development Workflow

1. **Make changes** in TypeScript source files under `src/`
2. **Type check** with `npm run typecheck`
3. **Lint** with `npm run lint` (if configured)
4. **Build** with `npm run build` to compile to `dist/`
5. **Test** with `npm test` or targeted test commands
6. **Run locally** with `npm run dev` for development or `npm start` for production
7. **Docker testing**: Use `npm run docker:build` and `npm run docker:up` for containerized testing

## Environment Configuration

Required API keys (see `.env.template` for full list):
- `ELEVENLABS_API_KEY` - Voice synthesis
- `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN` - Phone calls
- `SENDGRID_API_KEY` - Email automation
- `STRIPE_SECRET_KEY` - Payment processing
- `COINBASE_COMMERCE_API_KEY` - Crypto payments
- `OPENAI_API_KEY` - AI/LLM access
- Google Cloud credentials for various services
- Exchange API keys (optional): Binance, Kraken, Gemini

## Important Notes

- The system is designed for autonomous 24/7 operation
- GitHub Actions workflows handle scheduled runs
- Output syncs to Google Sheets (ID: `1u1USJDfPR5qZSb6-Zs4JyIyDFLLLfZhHKr1KJcFKrgU`)
- Smart contracts deploy to Sepolia testnet
- Dashboard serves on port 4000

## Common Tasks for Copilot

When making changes:
1. **Adding a new feature**: Create a new module in the appropriate `src/` subdirectory, define types in `types.ts`, integrate with the orchestrator
2. **API integration**: Add credentials to `.env.template`, implement in `src/integrations/`, handle errors gracefully
3. **Fixing bugs**: Check logs in `logs/`, use type checking, add tests to prevent regression
4. **Updating dependencies**: Test thoroughly as the system integrates many external services
5. **Documentation**: Update relevant `.md` files in the root directory

## Security Best Practices

- Always run security scans on new code (Snyk integration active)
- Validate and sanitize all external inputs
- Use environment variables for secrets
- Follow the principle of least privilege for API access
- Review smart contract code carefully before deployment
- Implement rate limiting for API calls
- Use HTTPS/TLS for all external communications
