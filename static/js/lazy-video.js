document.addEventListener('DOMContentLoaded', function() {
    function loadVideo(video) {
        if (video.dataset.loaded === 'true') return;

        const source = video.querySelector('source');
        if (source && source.dataset.src) {
            source.src = source.dataset.src;
            video.load();
            video.dataset.loaded = 'true';
            video.play().catch(function() {});
        }
    }

    function setupLazyLoading() {
        const videos = document.querySelectorAll('video[data-lazy="true"]');

        const videoObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const video = entry.target;
                    loadVideo(video);
                    observer.unobserve(video);
                }
            });
        }, {
            rootMargin: '50px 0px',
            threshold: 0.1
        });

        videos.forEach(video => {
            const source = video.querySelector('source');
            if (source && source.src) {
                source.dataset.src = source.src;
                source.removeAttribute('src');
            }
            videoObserver.observe(video);
        });
    }

    function setupVideoPlayback() {
        document.addEventListener('click', function(e) {
            const tab = e.target.closest('.tabs li');
            if (tab) {
                setTimeout(() => {
                    const activeContent = document.querySelector('.video-content.is-active');
                    if (activeContent) {
                        const videos = activeContent.querySelectorAll('video[data-lazy="true"]');
                        videos.forEach(function(video) {
                            loadVideo(video);
                            video.play().catch(function() {});
                        });
                    }
                }, 100);
            }
        });
    }

    window.addEventListener('beforeunload', function() {
        document.querySelectorAll('video').forEach(function(video) {
            if (!video.paused) video.pause();
        });
    });

    setupLazyLoading();
    setupVideoPlayback();
});