# User Components Documentation

## Overview

This project now uses reusable components for the topbar and footer across all user pages. This eliminates the need to duplicate code and ensures consistency across the application.

## Components Created

### 1. User Topbar Component (`user_topbar/2`)
- **File**: `lib/my_belia_web/components/user_components.ex`
- **Function**: `user_topbar(assigns, opts \\ [])`
- **Purpose**: Provides consistent navigation header across all authenticated user pages
- **Image Size Options**: 
  - `:brand_logo_width` - Width of KBSS logo (default: "auto")
  - `:brand_logo_height` - Height of KBSS logo (default: "auto")
  - `:profile_image_width` - Width of profile image (default: "auto")
  - `:profile_image_height` - Height of profile image (default: "auto")

### 2. Public Topbar Component (`public_topbar/2`)
- **File**: `lib/my_belia_web/components/user_components.ex`
- **Function**: `public_topbar(assigns, opts \\ [])`
- **Purpose**: Provides consistent navigation header for public landing pages (with LOG MASUK/DAFTAR buttons)
- **Image Size Options**:
  - `:brand_logo_width` - Width of KBSS logo (default: "auto")
  - `:brand_logo_height` - Height of KBSS logo (default: "auto")

### 3. User Footer Component (`user_footer/2`)
- **File**: `lib/my_belia_web/components/user_components.ex`
- **Function**: `user_footer(assigns, opts \\ [])`
- **Purpose**: Provides consistent footer across all pages
- **Image Size Options**:
  - `:footer_logo_width` - Width of KBS footer logo (default: "auto")
  - `:footer_logo_height` - Height of KBS footer logo (default: "auto")
  - `:social_ellipse_width` - Width of social media ellipses (default: "auto")
  - `:social_ellipse_height` - Height of social media ellipses (default: "auto")
  - `:social_image_width` - Width of social media icons (default: "auto")
  - `:social_image_height` - Height of social media icons (default: "auto")
  - `:agency_logo_width` - Width of agency logos (default: "auto")
  - `:agency_logo_height` - Height of agency logos (default: "auto")

## How to Use

### For Existing Pages
To update an existing user page to use the components:

1. **Replace the topbar section** with:
   ```heex
   <%= user_topbar(assigns) %>
   ```

2. **Replace the footer section** with:
   ```heex
   <%= user_footer(assigns) %>
   ```

### For New Pages
To create a new user page with the components:

1. **Create a new template file** (e.g., `new_page.html.heex`)
2. **Add the components**:
   ```heex
   <%= user_topbar(assigns) %>
   
   <!-- Your page content here -->
   <section class="your-content">
     <div class="container">
       <h1>Your Page Title</h1>
       <!-- Add your content -->
     </div>
   </section>
   
   <%= user_footer(assigns) %>
   ```

### Custom Image Sizes
You can customize image sizes by passing options:

```heex
<!-- Custom topbar image sizes -->
<%= user_topbar(assigns, [
  brand_logo_width: "200px",
  brand_logo_height: "80px",
  profile_image_width: "50px",
  profile_image_height: "50px"
]) %>

<!-- Custom footer image sizes -->
<%= user_footer(assigns, [
  footer_logo_width: "120px",
  footer_logo_height: "120px",
  social_ellipse_width: "45px",
  social_ellipse_height: "45px",
  social_image_width: "25px",
  social_image_height: "25px",
  agency_logo_width: "100px",
  agency_logo_height: "100px"
]) %>

<!-- Public topbar with custom sizes -->
<%= public_topbar(assigns, [
  brand_logo_width: "180px",
  brand_logo_height: "70px"
]) %>
```

3. **Add a route** in `lib/my_belia_web/router.ex`:
   ```elixir
   get "/your-new-page", PageController, :your_new_page
   ```

4. **Add a controller function** in `lib/my_belia_web/controllers/page_controller.ex`:
   ```elixir
   def your_new_page(conn, _params) do
     render(conn, :your_new_page, layout: false)
   end
   ```

## Files Updated

### Components
- ✅ `lib/my_belia_web/components/user_components.ex` (new file)
- ✅ `lib/my_belia_web/components/core_components.ex` (imported user components)

### Pages Updated

#### User Pages (Authenticated)
- ✅ `lib/my_belia_web/controllers/page_html/user_home.html.heex`
- ✅ `lib/my_belia_web/controllers/page_html/user_profile.html.heex`
- ✅ `lib/my_belia_web/controllers/page_html/senarai_program.html.heex`
- ✅ `lib/my_belia_web/controllers/page_html/permohonan_geran.html.heex`
- ✅ `lib/my_belia_web/controllers/page_html/senarai_kursus.html.heex`
- ✅ `lib/my_belia_web/controllers/page_html/dokumen_sokongan.html.heex`

#### Landing Pages (Public & User)
- ✅ `lib/my_belia_web/controllers/page_html/home.html.heex` (public landing)
- ✅ `lib/my_belia_web/controllers/page_html/skim_geran.html.heex`
- ✅ `lib/my_belia_web/controllers/page_html/program_detail.html.heex`
- ✅ `lib/my_belia_web/controllers/page_html/course_detail.html.heex`
- ✅ `lib/my_belia_web/controllers/page_html/pengesahan_permohonan.html.heex`
- ✅ `lib/my_belia_web/controllers/page_html/dokumen_sokongan_geran.html.heex`

### Example Pages
- ✅ `lib/my_belia_web/controllers/page_html/example_user_page.html.heex` (new example page)
- ✅ `lib/my_belia_web/controllers/page_html/image_size_example.html.heex` (image size demonstration)
- ✅ Routes and controller functions added for example pages

## Benefits

1. **DRY Principle**: Don't Repeat Yourself - no more duplicated code
2. **Consistency**: All user pages have identical topbar and footer
3. **Maintainability**: Update once, applies everywhere
4. **Cleaner Code**: Templates are shorter and more focused
5. **Easier Development**: New pages can be created quickly
6. **Flexible Image Sizing**: Customize image sizes per page or globally
7. **Backward Compatible**: Existing usage continues to work without changes

## Example Usage

- Visit `/example-user-page` to see a demonstration of how easy it is to create new pages with these components.
- Visit `/image-size-example` to see examples of customizing image sizes in the topbar and footer.

## Maintenance

When you need to update the topbar or footer:

1. **Edit the component** in `lib/my_belia_web/components/user_components.ex`
2. **Changes automatically apply** to all pages using the components
3. **No need to update individual pages**

## Notes

- The components automatically handle user authentication status
- Admin links are conditionally shown based on user role
- All existing functionality is preserved
- CSS styles remain the same 