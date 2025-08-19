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

// WYSIWYG Editor functionality
document.addEventListener('DOMContentLoaded', function() {
  initializeWysiwygEditors();
});

// Initialize WYSIWYG editors for description fields
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

