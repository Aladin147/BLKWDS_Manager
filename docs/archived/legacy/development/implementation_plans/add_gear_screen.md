# [LEGACY] Add Gear Screen Implementation Plan

> **WARNING**: This document is legacy documentation kept for historical reference.
> It may contain outdated information. Please refer to the current documentation in the main docs directory.
> Last updated: 2025-04-16


## Overview
The Add Gear screen will allow users to add new equipment to the inventory. This screen will include a form for entering gear details, image upload functionality, and validation.

## UI Components
1. **AppBar** with title and back button
2. **Form** with the following fields:
   - Name (required)
   - Category (dropdown, required)
   - Description (optional)
   - Serial Number (optional)
   - Purchase Date (optional)
   - Image Upload (optional)
3. **Save Button** to submit the form
4. **Cancel Button** to return to the previous screen

## Data Flow
1. User enters gear details in the form
2. User uploads an image (optional)
3. User clicks Save
4. Validation is performed
5. If validation passes, gear is saved to the database
6. User is returned to the previous screen with a success message

## Implementation Steps

### 1. Create Model Extensions
- Add additional fields to the Gear model (description, serialNumber, purchaseDate)
- Update database schema to include new fields

### 2. Create UI Components
- Create AddGearScreen widget
- Implement form with validation
- Create ImagePicker component for image upload
- Implement category dropdown

### 3. Implement Controller
- Create AddGearController class
- Add methods for form validation
- Add method for saving gear to database
- Add method for handling image upload

### 4. Connect to Database
- Update DBService to handle new gear fields
- Implement image storage functionality
- Add error handling for database operations

### 5. Testing
- Test form validation
- Test image upload
- Test database operations
- Test error handling

## Dependencies
- file_selector: For image selection
- path_provider: For managing file paths
- intl: For date formatting

## Estimated Time
- UI Implementation: 1 day
- Controller Implementation: 1 day
- Database Integration: 1 day
- Testing and Refinement: 1 day
- Total: 4 days
