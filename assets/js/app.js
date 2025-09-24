// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Import search functionality
import "./search.js"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// File upload handling
function initializeAdminSidebar() {
  try {
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');
    const menuToggle = document.getElementById('menu-toggle');

    console.info('[AdminSidebar] init', {
      sidebar: !!sidebar,
      mainContent: !!mainContent,
      menuToggle: !!menuToggle,
      url: window.location.pathname
    });

    // Restore persisted state
    const persisted = localStorage.getItem('adminSidebarHidden');
    if (persisted === 'true' && sidebar && mainContent) {
      sidebar.classList.add('hidden');
      mainContent.classList.add('sidebar-hidden');
    }

    if (menuToggle && sidebar && mainContent) {
      menuToggle.onclick = function () {
        sidebar.classList.toggle('hidden');
        mainContent.classList.toggle('sidebar-hidden');
        // Fallback inline style to ensure movement even if CSS is overridden
        const isHidden = sidebar.classList.contains('hidden');
        if (isHidden) {
          sidebar.style.transform = 'translateX(-100%)';
          sidebar.style.width = '0px';
          mainContent.style.marginLeft = '0px';
        } else {
          sidebar.style.transform = '';
          sidebar.style.width = '';
          // Explicit fallback to sidebar width
          mainContent.style.marginLeft = '280px';
        }
        localStorage.setItem('adminSidebarHidden', isHidden);
      };
    }

    // Sidebar dropdowns that use .dropdown-toggle + data-dropdown id
    const toggles = document.querySelectorAll('.dropdown-toggle');
    console.info('[AdminSidebar] dropdown toggles found:', toggles.length);
    toggles.forEach((toggle) => {
      toggle.onclick = function (e) {
        e.preventDefault();
        e.stopPropagation();
        const targetId = this.getAttribute('data-dropdown');
        const menu = document.getElementById(targetId);
        console.info('[AdminSidebar] dropdown click', { targetId, menuExists: !!menu });
        if (!menu) return;
        // Close other open menus
        document.querySelectorAll('.dropdown-menu.show').forEach((el) => {
          if (el !== menu) el.classList.remove('show');
        });
        this.classList.toggle('active');
        menu.classList.toggle('show');
        // Inline fallback for visibility
        if (menu.classList.contains('show')) {
          menu.style.display = 'block';
        } else {
          menu.style.display = '';
        }
      };
    });

    // Close when clicking outside
    document.addEventListener('click', function (e) {
      if (!e.target.closest('.sidebar')) {
        document.querySelectorAll('.dropdown-menu.show').forEach((el) => el.classList.remove('show'));
        document.querySelectorAll('.dropdown-toggle.active').forEach((el) => el.classList.remove('active'));
      }
    });
  } catch (err) {
    console.error('initializeAdminSidebar error', err);
  }
}

document.addEventListener('DOMContentLoaded', function () {
  initializeFileUploads();
  initializeWysiwygEditors();
  initializeAdminSidebar();
});

window.addEventListener('phx:page-loading-stop', function () {
  // Re-bind after LV patches
  initializeAdminSidebar();
});

// Initialize file upload functionality
function initializeFileUploads() {
  const fileInputs = document.querySelectorAll('input[type="file"]');
  
  fileInputs.forEach(input => {
    input.addEventListener('change', function(e) {
      const file = e.target.files[0];
      if (file) {
        console.log('File selected:', file.name, 'Size:', file.size, 'Type:', file.type);
        
        // Check if this is a document upload input (has .document-item parent)
        const documentItem = input.closest('.document-item');
        
        if (documentItem) {
          // This is a document upload input - handle document upload logic
          const statusElement = documentItem.querySelector('.document-status');
          const uploadButton = documentItem.querySelector('.upload-button');
          
          if (statusElement && uploadButton) {
            // Update status to show selected file
            statusElement.innerHTML = `
              <span class="status-selected">
                <span class="status-icon">ðŸ“Ž</span>
                ${file.name}
              </span>
            `;
            
            // Update button text
            uploadButton.innerHTML = `
              <span class="upload-icon">âœ…</span>
              <span class="upload-text">Fail Dipilih</span>
            `;
            uploadButton.style.background = '#28a745';
          }
          
          // Convert file to base64 and send to LiveView for document upload
          const reader = new FileReader();
          reader.onload = function(e) {
            const base64Data = e.target.result;
            console.log('File converted to base64, length:', base64Data.length);
            
            // Check if liveSocket exists
            console.log('window.liveSocket exists:', !!window.liveSocket);
            if (window.liveSocket) {
              console.log('liveSocket methods:', Object.keys(window.liveSocket));
              console.log('liveSocket.execJS exists:', typeof window.liveSocket.execJS);
            }
            
            // Send file data to LiveView
            if (window.liveSocket && window.liveSocket.execJS) {
              const fileKey = input.name;
              console.log('Sending upload-file event with fileKey:', fileKey);
              
              try {
                // Since pushEvent doesn't exist, let's use a different approach
                // We'll trigger a custom event on the document that LiveView can listen to
                console.log('Using custom event approach');
                
                // Create a custom event with the file data
                const uploadEvent = new CustomEvent('file-upload', {
                  detail: {
                    file_key: fileKey,
                    filename: file.name,
                    content_type: file.type,
                    file_data: base64Data
                  }
                });
                
                // Dispatch the event on the document
                document.dispatchEvent(uploadEvent);
                console.log('Custom file-upload event dispatched');
                
                // Also try to trigger a form submission with the file data
                const form = input.closest('form');
                if (form) {
                  console.log('Found form, triggering submit with file data');
                  
                  // Create a hidden input with the file data
                  const hiddenInput = document.createElement('input');
                  hiddenInput.type = 'hidden';
                  hiddenInput.name = 'upload_file_data';
                  hiddenInput.value = JSON.stringify({
                    file_key: fileKey,
                    filename: file.name,
                    content_type: file.type,
                    file_data: base64Data
                  });
                  
                  form.appendChild(hiddenInput);
                  
                  // Trigger the form submit
                  const submitEvent = new Event('submit', { bubbles: true, cancelable: true });
                  form.dispatchEvent(submitEvent);
                  
                  // Remove the hidden input
                  form.removeChild(hiddenInput);
                  console.log('Form submit triggered with file data');
                }
                
              } catch (error) {
                console.error('Error sending upload-file event:', error);
              }
            } else {
              console.error('liveSocket or execJS not available');
              console.log('Available methods on liveSocket:', window.liveSocket ? Object.getOwnPropertyNames(window.liveSocket) : 'liveSocket is null');
            }
          };
          
          reader.onerror = function(error) {
            console.error('FileReader error:', error);
          };
          
          reader.readAsDataURL(file);
        } else {
          // This is not a document upload input (e.g., avatar upload)
          console.log('Non-document file input detected (likely avatar upload)');
          
          // Show visual feedback for avatar upload if needed
          const avatarImg = document.getElementById('user-avatar');
          if (avatarImg && input.id === 'avatar-upload') {
            const reader = new FileReader();
            reader.onload = function(e) {
              avatarImg.src = e.target.result;
              console.log('Avatar preview updated');
              
              // Set flag to indicate avatar was uploaded
              const avatarFlag = document.getElementById('avatar-uploaded-flag');
              if (avatarFlag) {
                avatarFlag.value = 'true';
                console.log('Avatar upload flag set to true');
              }
              
              // Set trigger to force avatar upload processing
              const triggerField = document.getElementById('trigger-avatar-upload');
              if (triggerField) {
                triggerField.value = 'true';
                console.log('Avatar upload trigger set to true');
              }
              
              // Store file data as base64 in hidden field
              const fileDataField = document.getElementById('avatar-file-data');
              if (fileDataField) {
                fileDataField.value = e.target.result;
                console.log('Avatar file data stored in hidden field');
              }
            };
            reader.readAsDataURL(file);
          }
        }
      }
    });
  });
}

// WYSIWYG Editor functionality
function initializeWysiwygEditors() {
  // Check if Quill is available (loaded via CDN)
  if (typeof Quill === 'undefined') {
    console.warn('Quill.js not loaded. Loading from CDN...');
    loadQuillFromCDN().then(() => {
      initializeWysiwygEditors();
    });
    return;
  }

  // Initialize editor for new program form
  const descriptionField = document.getElementById('program-description');
  if (descriptionField && !descriptionField.classList.contains('quill-initialized')) {
    initializeQuillEditor(descriptionField, 'new-program');
  }

  // Initialize editor for edit program form
  const editDescriptionField = document.getElementById('edit-program-description');
  if (editDescriptionField && !editDescriptionField.classList.contains('quill-initialized')) {
    initializeQuillEditor(editDescriptionField, 'edit-program');
  }

  // Initialize editor for new course form
  const courseDescriptionField = document.getElementById('course-description');
  if (courseDescriptionField && !courseDescriptionField.classList.contains('quill-initialized')) {
    initializeQuillEditor(courseDescriptionField, 'new-course');
  }

  // Initialize editor for edit course form
  const editCourseDescriptionField = document.getElementById('edit-course-description');
  if (editCourseDescriptionField && !editCourseDescriptionField.classList.contains('quill-initialized')) {
    initializeQuillEditor(editCourseDescriptionField, 'edit-course');
  }
}

// Function to set content in WYSIWYG editor
function setWysiwygContent(fieldId, content) {
  const field = document.getElementById(fieldId);
  console.log('Setting WYSIWYG content for:', fieldId, 'Content:', content);
  if (field && field.quillInstance) {
    field.quillInstance.root.innerHTML = content;
    field.value = content;
    console.log('Content set successfully');
  } else {
    console.log('Field or Quill instance not found:', fieldId);
  }
}

// Load Quill.js from CDN
function loadQuillFromCDN() {
  return new Promise((resolve, reject) => {
    // Load Quill CSS
    const quillCSS = document.createElement('link');
    quillCSS.rel = 'stylesheet';
    quillCSS.href = 'https://cdn.quilljs.com/1.3.6/quill.snow.css';
    document.head.appendChild(quillCSS);

    // Load Quill JS
    const quillJS = document.createElement('script');
    quillJS.src = 'https://cdn.quilljs.com/1.3.6/quill.min.js';
    quillJS.onload = resolve;
    quillJS.onerror = reject;
    document.head.appendChild(quillJS);
  });
}

// Initialize Quill editor for a specific field
function initializeQuillEditor(textarea, editorId) {
  console.log('Initializing Quill editor for:', editorId, 'Textarea value:', textarea.value);
  
  // Create container for the editor
  const editorContainer = document.createElement('div');
  editorContainer.id = `quill-editor-${editorId}`;
  editorContainer.className = 'quill-editor-container';
  editorContainer.style.cssText = `
    border: 1px solid #d1d5db;
    border-radius: 0.5rem;
    margin-top: 0.5rem;
    background: white;
  `;

  // Insert container after textarea
  textarea.parentNode.insertBefore(editorContainer, textarea.nextSibling);

  // Hide the original textarea
  textarea.style.display = 'none';
  textarea.classList.add('quill-initialized');

  // Initialize Quill editor
  const quill = new Quill(editorContainer, {
    theme: 'snow',
    modules: {
      toolbar: [
        [{ 'header': [1, 2, 3, false] }],
        ['bold', 'italic', 'underline', 'strike'],
        [{ 'color': [] }, { 'background': [] }],
        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
        [{ 'align': [] }],
        ['link', 'image'],
        ['clean']
      ]
    },
    placeholder: textarea.placeholder || 'Masukkan diskripsi program dengan format yang diingini...'
  });

  // Set initial content if textarea has value
  if (textarea.value) {
    console.log('Setting initial content in Quill editor:', textarea.value);
    quill.root.innerHTML = textarea.value;
  }

  // Update textarea value when editor content changes
  quill.on('text-change', function() {
    textarea.value = quill.root.innerHTML;
  });

  // Store reference to quill instance
  textarea.quillInstance = quill;
  console.log('Quill editor initialized for:', editorId);

  // Add custom styles for the editor
  addQuillStyles();
}

// Add custom styles for Quill editor
function addQuillStyles() {
  if (document.getElementById('quill-custom-styles')) return;

  const style = document.createElement('style');
  style.id = 'quill-custom-styles';
  style.textContent = `
    .quill-editor-container .ql-editor {
      min-height: 200px;
      font-size: 14px;
      line-height: 1.6;
      color: #374151;
    }
    
    .quill-editor-container .ql-toolbar {
      border-top: 1px solid #d1d5db;
      border-left: 1px solid #d1d5db;
      border-right: 1px solid #d1d5db;
      border-bottom: none;
      border-radius: 0.5rem 0.5rem 0 0;
      background: #f9fafb;
    }
    
    .quill-editor-container .ql-container {
      border-bottom: 1px solid #d1d5db;
      border-left: 1px solid #d1d5db;
      border-right: 1px solid #d1d5db;
      border-top: none;
      border-radius: 0 0 0.5rem 0.5rem;
    }
    
    .quill-editor-container .ql-editor:focus {
      outline: none;
    }
    
    .quill-editor-container .ql-editor h1,
    .quill-editor-container .ql-editor h2,
    .quill-editor-container .ql-editor h3 {
      margin: 0.5em 0;
      font-weight: 600;
    }
    
    .quill-editor-container .ql-editor p {
      margin: 0.5em 0;
    }
    
    .quill-editor-container .ql-editor ul,
    .quill-editor-container .ql-editor ol {
      margin: 0.5em 0;
      padding-left: 1.5em;
    }
    
    .quill-editor-container .ql-editor a {
      color: #2563eb;
      text-decoration: underline;
    }
    
    .quill-editor-container .ql-editor img {
      max-width: 100%;
      height: auto;
      margin: 0.5em 0;
    }
  `;
  document.head.appendChild(style);
}

// Dropdown functionality
document.addEventListener('DOMContentLoaded', function() {
  const dropdowns = document.querySelectorAll('.dropdown');
  
  dropdowns.forEach(dropdown => {
    const dropdownContent = dropdown.querySelector('.dropdown-content');
    const dropdownTrigger = dropdown.querySelector('span');
    
    // Toggle dropdown on click
    dropdownTrigger.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      
      // Close all other dropdowns
      dropdowns.forEach(otherDropdown => {
        if (otherDropdown !== dropdown) {
          otherDropdown.classList.remove('active');
        }
      });
      
      // Toggle current dropdown
      dropdown.classList.toggle('active');
    });
    
    // Close dropdown when clicking on a link
    const dropdownLinks = dropdownContent.querySelectorAll('a');
    dropdownLinks.forEach(link => {
      link.addEventListener('click', function() {
        dropdown.classList.remove('active');
      });
    });
  });
  
  // Close dropdown when clicking outside
  document.addEventListener('click', function(e) {
    if (!e.target.closest('.dropdown')) {
      dropdowns.forEach(dropdown => {
        dropdown.classList.remove('active');
      });
    }
  });
});



// Enhanced dropdown functionality with debugging
document.addEventListener("DOMContentLoaded", function() {
  console.log("Dropdown script loaded");
  
  const dropdowns = document.querySelectorAll(".dropdown");
  console.log("Found dropdowns:", dropdowns.length);
  
  dropdowns.forEach((dropdown, index) => {
    const dropdownContent = dropdown.querySelector(".dropdown-content");
    const dropdownTrigger = dropdown.querySelector("span");
    
    console.log(`Dropdown ${index}:`, dropdown, dropdownContent, dropdownTrigger);
    
    if (dropdownTrigger) {
      dropdownTrigger.addEventListener("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        console.log("Dropdown clicked");
        
        // Close all other dropdowns
        dropdowns.forEach(otherDropdown => {
          if (otherDropdown !== dropdown) {
            otherDropdown.classList.remove("active");
          }
        });
        
        // Toggle current dropdown
        dropdown.classList.toggle("active");
        console.log("Dropdown active:", dropdown.classList.contains("active"));
      });
    }
    
    // Close dropdown when clicking on a link
    if (dropdownContent) {
      const dropdownLinks = dropdownContent.querySelectorAll("a");
      dropdownLinks.forEach(link => {
        link.addEventListener("click", function() {
          dropdown.classList.remove("active");
        });
      });
    }
  });
  
  // Close dropdown when clicking outside
  document.addEventListener("click", function(e) {
    if (!e.target.closest(".dropdown")) {
      dropdowns.forEach(dropdown => {
        dropdown.classList.remove("active");
      });
    }
  });
});


// Simple dropdown functionality
document.addEventListener("DOMContentLoaded", function() {
  console.log("Dropdown script loaded");
  
  const dropdowns = document.querySelectorAll(".dropdown");
  console.log("Found dropdowns:", dropdowns.length);
  
  dropdowns.forEach((dropdown, index) => {
    const dropdownTrigger = dropdown.querySelector("span");
    
    if (dropdownTrigger) {
      dropdownTrigger.addEventListener("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        console.log("Dropdown clicked");
        
        // Close all other dropdowns
        dropdowns.forEach(otherDropdown => {
          if (otherDropdown !== dropdown) {
            otherDropdown.classList.remove("active");
          }
        });
        
        // Toggle current dropdown
        dropdown.classList.toggle("active");
        console.log("Dropdown active:", dropdown.classList.contains("active"));
      });
    }
  });
  
  // Close dropdown when clicking outside
  document.addEventListener("click", function(e) {
    if (!e.target.closest(".dropdown")) {
      dropdowns.forEach(dropdown => {
        dropdown.classList.remove("active");
      });
    }
  });
});
