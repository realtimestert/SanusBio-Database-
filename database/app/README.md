# SanusBio Ferret Colony Manager

A Progressive Web App (PWA) for managing ferret colonies with health tracking, breeding management, and location monitoring.

## Features

✅ **Ferret Management**
- View and search all ferrets in the colony
- Detailed individual ferret profiles
- Track genealogy (mother/father)
- Monitor vaccination schedules

✅ **Health Tracking**
- Record weight checks
- Log baths and nail trims
- Track health events with notes
- View health history timeline

✅ **Breeding Management**
- Monitor females in estrus
- Record mating events
- Track breeding history
- Partner tracking

✅ **Location Management**
- View ferrets by location
- Move ferrets between cages
- Track location history

✅ **Mobile-Optimized**
- Responsive design for phones and tablets
- Can be installed as a mobile app
- Works offline with cached data
- Touch-friendly interface

## Installation

### Desktop/Laptop
1. Open `index.html` in a modern web browser (Chrome, Firefox, Safari, Edge)
2. The app will load with mock data

### Mobile Device
1. Open `index.html` in your mobile browser
2. Tap the browser menu (three dots)
3. Select "Add to Home Screen" or "Install App"
4. The app will now work like a native mobile app

## Usage

### Navigation
- Use the bottom navigation bar to switch between sections:
  - **Ferrets**: Main list of all ferrets
  - **Health**: Recent health events
  - **Breeding**: Estrus tracking and mating records
  - **Locations**: Housing management

### Adding Data
- Tap the **+ button** (floating action button) to add new health events
- Tap on any ferret card to view detailed information
- Use the action buttons in detail view to:
  - Add health events
  - Record mating
  - Move ferrets

### Searching
- Use the search bar on the main Ferrets page
- Search by ferret name, ID, or location

## Data Storage

The app currently uses **localStorage** for data persistence:
- Data is stored in your browser
- Mock data is generated on first load
- All changes are saved automatically
- Data persists between sessions
- To reset: Clear browser data or use browser developer tools

## Backend Integration (Future)

This app is designed to connect to a MySQL database with the provided schema. To integrate:

1. Create a REST API with endpoints:
   - `GET /api/ferrets` - List all ferrets
   - `GET /api/ferrets/:id` - Get ferret details
   - `POST /api/ferrets` - Create new ferret
   - `PUT /api/ferrets/:id` - Update ferret
   - `POST /api/health-events` - Add health event
   - `POST /api/breeding-events` - Record breeding
   - `POST /api/location-changes` - Update location

2. Replace mock data functions with API calls:
   - Update `loadFerrets()` to fetch from API
   - Update `saveFerrets()` to POST to API
   - Add error handling and loading states

3. Add authentication if needed

## Browser Compatibility

- ✅ Chrome/Edge (Recommended)
- ✅ Firefox
- ✅ Safari (iOS 11.3+)
- ✅ Mobile browsers

## Features to Add (Future Enhancements)

- [ ] Connect to real MySQL database
- [ ] User authentication
- [ ] Photo uploads for ferrets
- [ ] Export data (CSV, PDF reports)
- [ ] Push notifications for vaccines
- [ ] Barcode/QR code scanning
- [ ] Advanced filtering and sorting
- [ ] Batch operations
- [ ] Pregnancy tracking
- [ ] Kit management
- [ ] Medical treatment logs

## Technical Details

**Built with:**
- React 18 (via CDN)
- Vanilla CSS with CSS Variables
- LocalStorage API
- Service Workers for PWA
- Google Fonts (Outfit, Source Sans 3)

**File Structure:**
```
sanusbio-app/
├── index.html      # Main application (single-file)
├── manifest.json   # PWA manifest
├── sw.js          # Service worker
└── README.md      # This file
```

## Development

To modify the app:
1. Edit `index.html` - All React components and styles are in this file
2. Mock data generation is in the `generateMockData()` function
3. Update the service worker version in `sw.js` when deploying updates

## Support

For issues or questions, refer to your database schema documentation at:
`sanusbio_database_schema.sql`

---

**Version:** 1.0.0  
**Last Updated:** February 2026
