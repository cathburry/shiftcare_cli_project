# ShiftCare Client Manager

A command-line application for managing client data with search and duplicate detection capabilities.

## Features

- Search clients by name (partial matching, case insensitive)
- Find clients with duplicate email addresses
- Handles both local JSON files and remote URLs
- Robust error handling

## Setup

1. **Prerequisites**:
   - Ruby 3.0+
   - Bundler (`gem install bundler`)

2. **Installation**:
   ```bash
   git clone https://github.com/cathburry/shiftcare_cli_project.git
   cd shiftcare_cli_project
   bundle install

## Usage

### Running the Application

1. **First run** (will download client data automatically):
   ```bash
   ruby bin/run

2. **Menu Options:**
   1. Search clients by name
      - Partial matches
      - Case insensitive
   2. Find duplicate emails
      - Exact matching
      - Case insensitive
   3. Exit
  
## Future Enhancements

1. Extended Search
2. API Integration
3. Performance
   1. Redis caching
   2. Database backend
   3. Background processing
   4. Multi-field search
