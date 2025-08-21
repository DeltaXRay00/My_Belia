# LiveView Migration Guide

## Overview

Your Phoenix application has been successfully converted to support LiveView while maintaining all existing server-side functionality. This means you now have **both** server-side routes and LiveView routes available.

## How It Works

### Current State
- ✅ **All existing server-side routes remain unchanged**
- ✅ **All existing templates and components remain unchanged**
- ✅ **All existing CSS and styling remain unchanged**
- ✅ **All existing functionality remains intact**

### New LiveView Routes
- 🆕 **LiveView routes are available with `/live` prefix**
- 🆕 **Same templates are used for both server-side and LiveView**
- 🆕 **Same authentication and authorization apply**

## Route Comparison

### User Pages

| Server-Side Route | LiveView Route | Description |
|------------------|----------------|-------------|
| `/laman-utama-pengguna` | `/live/laman-utama-pengguna` | User Dashboard |
| `/senarai_program` | `/live/senarai_program` | Program List |
| `/senarai_kursus` | `/live/senarai_kursus` | Course List |
| `/permohonan_geran` | `/live/permohonan_geran` | Grant Application |
| `/skim_geran` | `/live/skim_geran` | Grant Scheme |
| `/dokumen_sokongan_geran` | `/live/dokumen_sokongan_geran` | Grant Documents |
| `/pengesahan_permohonan` | `/live/pengesahan_permohonan` | Application Confirmation |
| `/profil_pengguna` | `/live/profil_pengguna` | User Profile |
| `/dokumen_sokongan` | `/live/dokumen_sokongan` | Support Documents |

### Admin Pages

| Server-Side Route | LiveView Route | Description |
|------------------|----------------|-------------|
| `/admin` | `/live/admin` | Admin Dashboard |
| `/admin/permohonan_program` | `/live/admin/permohonan_program` | Admin Program Management |
| `/admin/permohonan_kursus` | `/live/admin/permohonan_kursus` | Admin Course Management |
| `/admin/permohonan_geran` | `/live/admin/permohonan_geran` | Admin Grant Management |
| `/admin/permohonan_geran/lulus` | `/live/admin/permohonan_geran/lulus` | Approved Grants |
| `/admin/permohonan_geran/tolak` | `/live/admin/permohonan_geran/tolak` | Rejected Grants |
| `/admin/permohonan_geran/tidak_lengkap` | `/live/admin/permohonan_geran/tidak_lengkap` | Incomplete Grants |

### Public Pages

| Server-Side Route | LiveView Route | Description |
|------------------|----------------|-------------|
| `/` | `/live` | Home Page |
| `/home` | `/live/home` | Home Page |
| `/laman-utama` | `/live/laman-utama` | Home Page |

## Benefits of LiveView

### Real-time Features
- **No page refreshes** for form submissions
- **Real-time updates** for data changes
- **Better user experience** with faster interactions

### Enhanced Functionality
- **WebSocket communication** for real-time features
- **State management** for complex interactions
- **Reusable components** for better code organization

## Testing Your LiveView Routes

1. **Start your server:**
   ```bash
   mix phx.server
   ```

2. **Test server-side routes** (existing functionality):
   - Visit: `http://localhost:4000/senarai_program`
   - Visit: `http://localhost:4000/admin`

3. **Test LiveView routes** (new functionality):
   - Visit: `http://localhost:4000/live/senarai_program`
   - Visit: `http://localhost:4000/live/admin`

## Next Steps

### Option 1: Gradual Migration
- Keep using server-side routes for now
- Gradually migrate users to LiveView routes
- Test LiveView functionality thoroughly

### Option 2: Full Migration
- Update all internal links to use LiveView routes
- Remove server-side routes once LiveView is stable
- Update navigation components

### Option 3: Hybrid Approach
- Use LiveView for interactive pages (forms, lists)
- Keep server-side for static pages
- Choose based on page requirements

## Adding LiveView Features

### Example: Real-time Search
```elixir
# In your LiveView module
def handle_event("search", %{"query" => query}, socket) do
  programs = MyBelia.Programs.search_programs(query)
  {:noreply, assign(socket, programs: programs)}
end
```

### Example: Form Submission
```elixir
# In your LiveView module
def handle_event("submit_form", %{"form_data" => form_data}, socket) do
  case MyBelia.Programs.create_program(form_data) do
    {:ok, program} ->
      {:noreply, 
       socket 
       |> put_flash(:info, "Program created successfully!")
       |> redirect(to: ~p"/live/senarai_program")}
    
    {:error, changeset} ->
      {:noreply, assign(socket, changeset: changeset)}
  end
end
```

## File Structure

```
lib/my_belia_web/live/
├── page_live/
│   └── home_live.ex
├── user_live/
│   ├── user_home_live.ex
│   ├── senarai_program_live.ex
│   ├── senarai_kursus_live.ex
│   ├── permohonan_geran_live.ex
│   ├── skim_geran_live.ex
│   ├── dokumen_sokongan_geran_live.ex
│   ├── pengesahan_permohonan_live.ex
│   ├── user_profile_live.ex
│   └── dokumen_sokongan_live.ex
└── admin_live/
    ├── admin_live.ex
    ├── admin_permohonan_program_live.ex
    ├── admin_permohonan_kursus_live.ex
    ├── admin_permohonan_geran_live.ex
    ├── admin_permohonan_geran_lulus_live.ex
    ├── admin_permohonan_geran_tolak_live.ex
    └── admin_permohonan_geran_tidak_lengkap_live.ex
```

## Important Notes

- **Authentication**: LiveView routes use the same authentication as server-side routes
- **Templates**: Both server-side and LiveView use the same `.heex` templates
- **Components**: Your existing components work with both approaches
- **CSS**: All styling remains the same
- **Database**: Same models and schemas are used

## Troubleshooting

If you encounter issues:

1. **Check compilation**: `mix compile`
2. **Check routes**: `mix phx.routes`
3. **Check logs**: Look for LiveView-specific errors
4. **Test both routes**: Compare server-side vs LiveView behavior

Your application is now ready for LiveView while maintaining full backward compatibility! 