# MyBelia Application Routes Summary

## Public Routes (No Authentication Required)
These routes are accessible to all users without logging in.

### Landing and Authentication
- `GET /` - Landing page (home)
- `GET /laman-utama` - Alternative landing page
- `GET /home` - Alternative landing page
- `GET /log-masuk` - Login page
- `POST /log-masuk` - Login form submission
- `GET /daftar` - Registration page
- `POST /daftar` - Registration form submission
- `GET /log-keluar` - Logout (clears session)

---

## User Routes (Requires User Authentication)
These routes require users to be logged in (any user role).

### User Dashboard and Main Pages
- `GET /laman-utama-pengguna` - User home dashboard
- `GET /user-home` - Alternative user dashboard
- `GET /dashboard` - Alternative user dashboard

### User Profile
- `GET /profil_pengguna` - User profile page
- `GET /user-profile` - Alternative profile page
- `GET /profile` - Alternative profile page

### Documents and Support
- `GET /dokumen_sokongan` - Support documents page
- `GET /dokumen-sokongan` - Alternative documents page
- `GET /support-documents` - English alternative
- `GET /documents` - English alternative

### Program List
- `GET /senarai_program` - Program list page
- `GET /senarai-program` - Alternative program list
- `GET /program-list` - English alternative
- `GET /programs` - English alternative

### Course List
- `GET /senarai_kursus` - Course list page
- `GET /senarai-kursus` - Alternative course list
- `GET /course-list` - English alternative
- `GET /courses` - English alternative

---

## Admin Routes (Requires Admin Authentication)
These routes require users to be logged in AND have admin role.

### Admin Dashboard
- `GET /admin` - Admin dashboard
- `GET /admin-dashboard` - Alternative admin dashboard
- `GET /admin-panel` - Alternative admin panel
- `GET /admin-home` - Alternative admin home

---

## Authentication Rules

### General Users
- Can access all public routes
- Can access all user routes after logging in
- Cannot access admin routes (will be redirected to user dashboard)

### Admin Users
- Can access all public routes
- Can access all user routes
- Can access all admin routes
- Have additional admin privileges

### Unauthenticated Users
- Can only access public routes
- Will be redirected to login page when trying to access protected routes

---

## Route Organization

### Pipeline Structure
1. **`:browser`** - Basic browser pipeline (session, CSRF protection, etc.)
2. **`:auth`** - Requires user authentication (any role)
3. **`:admin_auth`** - Requires admin authentication (admin role only)

### Security Features
- CSRF protection on all forms
- Session-based authentication
- Role-based access control
- Automatic redirects for unauthorized access
- Flash messages for user feedback

---

## Navigation Flow

### For New Users
1. Visit `/` (landing page)
2. Click "DAFTAR" to register
3. After registration, redirected to `/log-masuk`
4. After login, redirected to `/laman-utama-pengguna`

### For Existing Users
1. Visit `/` (landing page)
2. Click "LOG MASUK" to login
3. After login, redirected to appropriate dashboard:
   - Regular users → `/laman-utama-pengguna`
   - Admin users → `/admin`

### For Admin Users
- Can access all user pages plus admin-specific pages
- Admin link appears in navigation when logged in as admin
- Can switch between user and admin views 