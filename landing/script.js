document.addEventListener('DOMContentLoaded', () => {
    // ── Theme Switcher ───────────────────────────────────────────────────
    const themeToggleBtn = document.getElementById('theme-toggle');
    const htmlElement = document.documentElement;

    // Get initial theme preference
    const savedTheme = localStorage.getItem('quickfit-theme');
    const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    
    // Set initial theme
    const initialTheme = savedTheme || (systemPrefersDark ? 'dark' : 'light');
    htmlElement.setAttribute('data-theme', initialTheme);

    // Toggle click handler
    themeToggleBtn.addEventListener('click', () => {
        const currentTheme = htmlElement.getAttribute('data-theme');
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        
        htmlElement.setAttribute('data-theme', newTheme);
        localStorage.setItem('quickfit-theme', newTheme);
    });

    // ── Mobile Menu Navigation Drawer ──────────────────────────────────
    const mobileNavToggle = document.querySelector('.mobile-nav-toggle');
    const mobileMenu = document.querySelector('.mobile-menu');
    const mobileMenuOverlay = document.querySelector('.mobile-menu-overlay');
    const mobileMenuLinks = document.querySelectorAll('.mobile-menu a');

    const toggleMobileMenu = () => {
        const isActive = mobileMenu.classList.toggle('active');
        mobileMenuOverlay.classList.toggle('active', isActive);
        
        // Update menu icon
        const icon = mobileNavToggle.querySelector('i');
        if (icon) {
            if (isActive) {
                icon.setAttribute('data-lucide', 'x');
            } else {
                icon.setAttribute('data-lucide', 'menu');
            }
            lucide.createIcons();
        }
    };

    const closeMobileMenu = () => {
        mobileMenu.classList.remove('active');
        mobileMenuOverlay.classList.remove('active');
        const icon = mobileNavToggle.querySelector('i');
        if (icon) {
            icon.setAttribute('data-lucide', 'menu');
            lucide.createIcons();
        }
    };

    mobileNavToggle.addEventListener('click', toggleMobileMenu);
    mobileMenuOverlay.addEventListener('click', closeMobileMenu);
    mobileMenuLinks.forEach(link => link.addEventListener('click', closeMobileMenu));

    // ── Contact Form Handler ─────────────────────────────────────────────
    const contactForm = document.getElementById('contact-form');
    const formSuccessMsg = document.getElementById('form-success');

    if (contactForm) {
        contactForm.addEventListener('submit', (e) => {
            e.preventDefault();
            
            // Show loading state
            const submitBtn = contactForm.querySelector('button[type="submit"]');
            const originalBtnText = submitBtn.textContent;
            submitBtn.textContent = 'Sending...';
            submitBtn.disabled = true;

            // Simulate form submission delay
            setTimeout(() => {
                contactForm.style.display = 'none';
                formSuccessMsg.style.display = 'flex';
                formSuccessMsg.style.opacity = '0';
                
                // Fade in success message
                setTimeout(() => {
                    formSuccessMsg.style.transition = 'opacity 0.5s ease';
                    formSuccessMsg.style.opacity = '1';
                }, 50);
            }, 1200);
        });
    }

    // ── Smooth Interactive Chart Animation on scroll ────────────────────
    const chartBars = document.querySelectorAll('.chart-bars .bar');
    
    const animateChart = () => {
        chartBars.forEach(bar => {
            const targetHeight = bar.style.height;
            bar.style.height = '0%';
            setTimeout(() => {
                bar.style.height = targetHeight;
            }, 300);
        });
    };

    // Trigger chart animation if scrolled into view
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateChart();
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    const chartContainer = document.querySelector('.app-mock-chart');
    if (chartContainer) {
        observer.observe(chartContainer);
    }
});
