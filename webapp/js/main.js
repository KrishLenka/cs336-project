/**
 * BuyMe Auction System - Main JavaScript
 * Handles client-side interactions and real-time updates
 */

// Format currency values
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    }).format(amount);
}

// Calculate and display time remaining for auctions
function updateTimeRemaining() {
    const timeElements = document.querySelectorAll('[data-close-time]');
    
    timeElements.forEach(element => {
        const closeTime = new Date(element.dataset.closeTime);
        const now = new Date();
        const diff = closeTime - now;
        
        if (diff <= 0) {
            element.textContent = 'Auction ended';
            element.classList.add('text-error');
            return;
        }
        
        const days = Math.floor(diff / (1000 * 60 * 60 * 24));
        const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        
        if (days > 0) {
            element.textContent = `${days}d ${hours}h left`;
        } else if (hours > 0) {
            element.textContent = `${hours}h ${minutes}m left`;
            element.classList.add('text-warning');
        } else {
            element.textContent = `${minutes}m left`;
            element.classList.add('text-error', 'pulse');
        }
    });
}

// Form validation for bid amounts
function validateBidForm(form) {
    const bidAmount = parseFloat(form.querySelector('[name="bidAmount"]').value);
    const minBid = parseFloat(form.dataset.minBid);
    
    if (isNaN(bidAmount) || bidAmount < minBid) {
        alert(`Bid must be at least ${formatCurrency(minBid)}`);
        return false;
    }
    return true;
}

// Auto-bid toggle functionality
function toggleAutoBid() {
    const autoBidCheckbox = document.getElementById('autoBidEnabled');
    const maxBidField = document.getElementById('maxAutoBid');
    
    if (autoBidCheckbox && maxBidField) {
        maxBidField.disabled = !autoBidCheckbox.checked;
        maxBidField.required = autoBidCheckbox.checked;
    }
}

// Category-specific field visibility
function updateCategoryFields() {
    const categorySelect = document.getElementById('categoryId');
    if (!categorySelect) return;
    
    const selectedOption = categorySelect.options[categorySelect.selectedIndex];
    const categoryName = selectedOption ? selectedOption.text.toLowerCase() : '';
    
    // Hide all category-specific sections first
    document.querySelectorAll('.category-fields').forEach(section => {
        section.style.display = 'none';
    });
    
    // Show relevant sections based on category
    if (categoryName.includes('laptop') || categoryName.includes('desktop') || 
        categoryName.includes('tablet') || categoryName.includes('computer')) {
        document.getElementById('computerFields')?.style.setProperty('display', 'block');
    }
    
    if (categoryName.includes('phone') || categoryName.includes('smartphone')) {
        document.getElementById('phoneFields')?.style.setProperty('display', 'block');
    }
    
    if (categoryName.includes('audio') || categoryName.includes('headphone') || 
        categoryName.includes('speaker') || categoryName.includes('earbud')) {
        document.getElementById('audioFields')?.style.setProperty('display', 'block');
    }
    
    if (categoryName.includes('gaming') || categoryName.includes('console') || 
        categoryName.includes('controller')) {
        document.getElementById('gamingFields')?.style.setProperty('display', 'block');
    }
}

// Confirm dangerous actions
function confirmAction(message) {
    return confirm(message || 'Are you sure you want to proceed?');
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    // Update time remaining every minute
    updateTimeRemaining();
    setInterval(updateTimeRemaining, 60000);
    
    // Set up category field toggling
    const categorySelect = document.getElementById('categoryId');
    if (categorySelect) {
        categorySelect.addEventListener('change', updateCategoryFields);
        updateCategoryFields(); // Initial call
    }
    
    // Set up auto-bid toggle
    const autoBidCheckbox = document.getElementById('autoBidEnabled');
    if (autoBidCheckbox) {
        autoBidCheckbox.addEventListener('change', toggleAutoBid);
        toggleAutoBid(); // Initial state
    }
    
    // Add fade-in animation to cards
    document.querySelectorAll('.auction-card, .card').forEach((card, index) => {
        card.style.animationDelay = `${index * 0.05}s`;
        card.classList.add('fade-in');
    });
});

// Search form enhancement
function enhanceSearchForm() {
    const form = document.querySelector('.search-form');
    if (!form) return;
    
    // Add debounced live search (optional enhancement)
    const searchInput = form.querySelector('input[name="keyword"]');
    if (searchInput) {
        let timeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(timeout);
            timeout = setTimeout(() => {
                // Could add live search suggestions here
            }, 300);
        });
    }
}

