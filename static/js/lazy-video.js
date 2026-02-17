document.addEventListener('DOMContentLoaded', function() {
    function loadVideo(video) {
        if (video.dataset.loaded === 'true') return;

        var source = video.querySelector('source');
        if (source && source.dataset.src) {
            source.src = source.dataset.src;
            video.load();
            video.dataset.loaded = 'true';
            video.play().catch(function() {});
        }
    }

    function loadAllVideosInSection(section) {
        var videos = section.querySelectorAll('video[data-lazy="true"]');
        videos.forEach(loadVideo);
    }

    function setupLazyLoading() {
        var sections = document.querySelectorAll('.content');

        var sectionObserver = new IntersectionObserver(function(entries, observer) {
            entries.forEach(function(entry) {
                if (entry.isIntersecting) {
                    loadAllVideosInSection(entry.target);
                    observer.unobserve(entry.target);
                }
            });
        }, {
            rootMargin: '200px 0px',
            threshold: 0.01
        });

        sections.forEach(function(section) {
            if (section.querySelector('video[data-lazy="true"]')) {
                var videos = section.querySelectorAll('video[data-lazy="true"]');
                videos.forEach(function(video) {
                    var source = video.querySelector('source');
                    if (source && source.src) {
                        source.dataset.src = source.src;
                        source.removeAttribute('src');
                    }
                });
                sectionObserver.observe(section);
            }
        });
    }

    function setupVideoPlayback() {
        document.addEventListener('click', function(e) {
            var tab = e.target.closest('.tabs li');
            if (tab) {
                setTimeout(function() {
                    var section = tab.closest('.content');
                    if (section) {
                        var activeContent = section.querySelector('.video-content.is-active');
                        if (activeContent) {
                            var videos = activeContent.querySelectorAll('video');
                            videos.forEach(function(video) {
                                loadVideo(video);
                                video.play().catch(function() {});
                            });
                        }
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