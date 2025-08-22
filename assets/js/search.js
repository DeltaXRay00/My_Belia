// Search functionality for all search bars
document.addEventListener('DOMContentLoaded', function() {
  // Initialize all search forms
  const searchForms = document.querySelectorAll('form[action*="search"]');
  
  searchForms.forEach(form => {
    const searchInput = form.querySelector('.search-input');
    const searchButton = form.querySelector('.search-button');
    
    // Add real-time search functionality
    if (searchInput) {
      searchInput.addEventListener('input', function(e) {
        const query = e.target.value.trim();
        
        // Add visual feedback
        if (query.length > 0) {
          searchInput.style.color = '#1408ff';
          if (searchButton) {
            searchButton.style.color = '#1408ff';
          }
        } else {
          searchInput.style.color = '#4f4f4f';
          if (searchButton) {
            searchButton.style.color = '#4f4f4f';
          }
        }
      });
      
      // Handle Enter key
      searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
          e.preventDefault();
          if (this.value.trim()) {
            form.submit();
          }
        }
      });
    }
    
    // Add click functionality to search button
    if (searchButton) {
      searchButton.addEventListener('click', function(e) {
        e.preventDefault();
        if (searchInput && searchInput.value.trim()) {
          form.submit();
        } else {
          // Add shake animation for empty search
          searchInput.style.animation = 'shake 0.5s ease-in-out';
          setTimeout(() => {
            searchInput.style.animation = '';
          }, 500);
        }
      });
    }
  });
  
  // Add shake animation CSS
  const style = document.createElement('style');
  style.textContent = `
    @keyframes shake {
      0%, 100% { transform: translateX(0); }
      25% { transform: translateX(-5px); }
      75% { transform: translateX(5px); }
    }
    
    .search-input:focus {
      outline: none;
      border-color: #1408ff;
    }
    
    .search-input::placeholder {
      transition: opacity 0.3s ease;
    }
    
    .search-input:focus::placeholder {
      opacity: 0.5;
    }
  `;
  document.head.appendChild(style);
});

// Auto-complete functionality for search inputs
function setupAutoComplete(searchInput, suggestions) {
  let currentFocus = -1;
  const autocompleteList = document.createElement('div');
  autocompleteList.className = 'autocomplete-items';
  searchInput.parentNode.appendChild(autocompleteList);
  
  searchInput.addEventListener('input', function() {
    const val = this.value;
    autocompleteList.innerHTML = '';
    currentFocus = -1;
    
    if (!val) {
      autocompleteList.style.display = 'none';
      return;
    }
    
    const matches = suggestions.filter(item => 
      item.toLowerCase().includes(val.toLowerCase())
    );
    
    if (matches.length > 0) {
      autocompleteList.style.display = 'block';
      matches.forEach(item => {
        const itemDiv = document.createElement('div');
        itemDiv.innerHTML = item.replace(
          new RegExp(val, 'gi'),
          match => `<strong>${match}</strong>`
        );
        itemDiv.addEventListener('click', function() {
          searchInput.value = item;
          autocompleteList.style.display = 'none';
        });
        autocompleteList.appendChild(itemDiv);
      });
    } else {
      autocompleteList.style.display = 'none';
    }
  });
  
  // Close autocomplete when clicking outside
  document.addEventListener('click', function(e) {
    if (!searchInput.contains(e.target) && !autocompleteList.contains(e.target)) {
      autocompleteList.style.display = 'none';
    }
  });
} 