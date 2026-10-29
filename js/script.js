/* ==========================================================================
   MANGXI Studio — AIGC 影像作品集 · 交互脚本
   预加载(百分比) / 平滑滚动 / 逐字浮现 / 磁吸按钮 / 自定义光标 / 滚动进度 / 视差
   ========================================================================== */

(function () {
  'use strict';

  const isTouch = !window.matchMedia('(hover: hover)').matches;
  const easeOut = (t) => 1 - Math.pow(1 - t, 3);

  /* ---------- 渲染作品：数据来自 js/works.js 的 WORKS 数组 ---------- */
  function renderWorks() {
    const grid = document.getElementById('worksGrid');
    if (!grid || typeof WORKS === 'undefined') return;
    const isVideo = (src) => /\.(mp4|webm|mov|m4v)$/i.test(src);
    grid.innerHTML = WORKS.map((w, i) => {
      const media = isVideo(w.src)
        ? `<video muted loop playsinline autoplay preload="auto"><source src="${w.src}" type="video/mp4" /></video>`
        : `<img src="${w.src}" alt="${w.title}" loading="lazy" />`;
      return `
      <article class="work" data-category="${w.cat}" data-reveal="up" data-i="${i}">
        <div class="work-media" data-i="${i}">
          ${media}
          <span class="work-watch">观看 ↗</span>
        </div>
        <div class="work-info">
          <h3 class="work-title">${w.title}</h3>
          <p class="work-meta">${w.meta}</p>
        </div>
      </article>
    `;
    }).join('');
  }
  renderWorks();

  /* ---------- 预加载：百分比计数 + 动态 logo ---------- */
  const preloader = document.getElementById('preloader');
  const countEl = document.getElementById('preloaderCount');

  if (countEl) {
    const LOAD_MS = 2100;
    const t0 = performance.now();
    (function tick(now) {
      const p = Math.min((now - t0) / LOAD_MS, 1);
      countEl.textContent = Math.round(p * 100) + '%';
      if (p < 1) requestAnimationFrame(tick);
    })(t0);
  }

  function finishPreload() {
    preloader.classList.add('done');
    document.body.classList.add('loaded');
    setTimeout(() => {
      // 预加载结束后再启动滚动进入动效，保证首屏动画节奏
      initReveal();
    }, 350);
  }

  setTimeout(finishPreload, 2300);

  /* ---------- 平滑滚动（Lenis，可选） ---------- */
  let lenis = null;
  if (window.Lenis) {
    lenis = new Lenis({ smoothWheel: true, lerp: 0.1, duration: 1.1 });
    function raf(time) { lenis.raf(time); requestAnimationFrame(raf); }
    requestAnimationFrame(raf);

    // 锚点跳转走 Lenis
    document.querySelectorAll('a[href^="#"]').forEach((a) => {
      a.addEventListener('click', (e) => {
        const id = a.getAttribute('href');
        if (id && id.length > 1) {
          e.preventDefault();
          lenis.scrollTo(id, { duration: 1.2, offset: 0 });
        }
      });
    });
  }

  /* ---------- 自定义光标 ---------- */
  const cursor = document.getElementById('cursor');
  const cursorDot = document.getElementById('cursorDot');
  if (!isTouch && cursor && cursorDot) {
    let cx = innerWidth / 2, cy = innerHeight / 2, rx = cx, ry = cy;
    window.addEventListener('mousemove', (e) => {
      cx = e.clientX; cy = e.clientY;
      cursorDot.style.left = cx + 'px';
      cursorDot.style.top = cy + 'px';
    });
    (function loop() {
      rx += (cx - rx) * 0.16;
      ry += (cy - ry) * 0.16;
      cursor.style.left = rx + 'px';
      cursor.style.top = ry + 'px';
      requestAnimationFrame(loop);
    })();

    document.querySelectorAll('a, button, .service, [data-cursor]').forEach((el) => {
      el.addEventListener('mouseenter', () => cursor.classList.add('is-hover'));
      el.addEventListener('mouseleave', () => cursor.classList.remove('is-hover'));
    });

    // 作品卡片：光标变为实心圆 + 「查看」标签
    document.querySelectorAll('.work').forEach((el) => {
      el.addEventListener('mouseenter', () => cursor.classList.add('is-hover', 'cursor-view'));
      el.addEventListener('mouseleave', () => cursor.classList.remove('is-hover', 'cursor-view'));
    });
  }

  /* ---------- 磁吸按钮（桌面端） ---------- */
  if (!isTouch) {
    document.querySelectorAll('.btn').forEach((btn) => {
      btn.addEventListener('mousemove', (e) => {
        const r = btn.getBoundingClientRect();
        const dx = e.clientX - (r.left + r.width / 2);
        const dy = e.clientY - (r.top + r.height / 2);
        btn.style.transform = `translate(${dx * 0.18}px, ${dy * 0.28}px)`;
      });
      btn.addEventListener('mouseleave', () => {
        btn.style.transform = '';
      });
    });
  }

  /* ---------- 导航：滚动方向 / 背景 ---------- */
  const header = document.getElementById('header');
  let lastY = window.scrollY;
  window.addEventListener('scroll', () => {
    const y = window.scrollY;
    header.classList.toggle('scrolled', y > 40);
    if (y > lastY && y > 300) header.classList.add('hidden');
    else header.classList.remove('hidden');
    lastY = y;
  }, { passive: true });

  /* ---------- 滚动进度条 ---------- */
  const progress = document.getElementById('scrollProgress');
  window.addEventListener('scroll', () => {
    const max = document.documentElement.scrollHeight - innerHeight;
    progress.style.width = (max > 0 ? (window.scrollY / max) * 100 : 0) + '%';
  }, { passive: true });

  /* ---------- 主推片视差 ---------- */
  const heroMedia = document.querySelector('.hero-media-inner');
  const heroVideo = heroMedia && heroMedia.querySelector('video');
  if (heroVideo) {
    let ticking = false;
    function updateParallax() {
      const r = heroMedia.getBoundingClientRect();
      if (r.bottom < 0 || r.top > innerHeight) { ticking = false; return; }
      const p = Math.max(0, Math.min(1, (innerHeight - r.top) / (innerHeight + r.height)));
      const y = (p - 0.5) * 80;
      heroVideo.style.transform = `scale(1.08) translateY(${y.toFixed(1)}px)`;
      ticking = false;
    }
    window.addEventListener('scroll', () => {
      if (!ticking) { ticking = true; requestAnimationFrame(updateParallax); }
    }, { passive: true });
    updateParallax();
  }

  /* ---------- 作品视频：悬浮播放 ---------- */
  const worksGrid = document.getElementById('worksGrid');
  worksGrid.addEventListener('mouseover', (e) => {
    const media = e.target.closest('.work-media');
    if (!media) return;
    if (e.relatedTarget && media.contains(e.relatedTarget)) return;
    const v = media.querySelector('video');
    if (v) v.play().catch(() => {});
  });
  worksGrid.addEventListener('mouseout', (e) => {
    const media = e.target.closest('.work-media');
    if (!media) return;
    if (e.relatedTarget && media.contains(e.relatedTarget)) return;
    const v = media.querySelector('video');
    if (v) { v.pause(); v.currentTime = 0; }
  });

  /* ---------- 分类筛选 ---------- */
  const filters = document.querySelectorAll('.filter');
  filters.forEach((btn) => {
    btn.addEventListener('click', () => {
      filters.forEach((f) => f.classList.remove('active'));
      btn.classList.add('active');
      const cat = btn.dataset.filter;
      document.querySelectorAll('#worksGrid .work').forEach((work) => {
        const match = cat === 'all' || work.dataset.category === cat;
        work.classList.toggle('hidden', !match);
      });
    });
  });

  /* ---------- 数字滚动 ---------- */
  const counters = document.querySelectorAll('[data-count]');
  function animateCount(el) {
    const target = +el.dataset.count;
    const duration = 1500;
    const start = performance.now();
    const step = (now) => {
      const p = Math.min((now - start) / duration, 1);
      el.textContent = Math.round(target * easeOut(p));
      if (p < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
  }

  /* ---------- 逐字拆分 ---------- */
  function splitChars(el) {
    const text = el.textContent;
    el.textContent = '';
    el.setAttribute('aria-label', text);
    const frag = document.createDocumentFragment();
    for (const ch of text) {
      const mask = document.createElement('span');
      mask.className = 'char-mask';
      const span = document.createElement('span');
      span.className = 'char';
      span.textContent = ch === ' ' ? '\u00A0' : ch;
      mask.appendChild(span);
      frag.appendChild(mask);
    }
    el.appendChild(frag);
    return el.querySelectorAll('.char');
  }

  /* ---------- 滚动进入动效 ---------- */
  const charEls = document.querySelectorAll('[data-reveal="chars"]');
  charEls.forEach(splitChars);

  let revealStarted = false;
  function initReveal() {
    if (revealStarted) return;
    revealStarted = true;

    const targets = document.querySelectorAll('[data-reveal]');
    const io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const el = entry.target;
        const type = el.dataset.reveal;
        const di = el.dataset.i != null ? parseInt(el.dataset.i, 10) : 0;
        const delay = di * 70;

        setTimeout(() => {
          if (type === 'chars') {
            el.querySelectorAll('.char').forEach((c, i) => {
              c.style.transitionDelay = (i * 28) + 'ms';
              c.style.transform = 'translateY(0)';
            });
          } else {
            el.classList.add('in');
          }
          io.unobserve(el);
        }, delay);
      });
    }, { threshold: 0.15 });

    targets.forEach((el) => io.observe(el));

    // 数字计数器进入视野时触发
    const statsObs = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          counters.forEach(animateCount);
          statsObs.disconnect();
        }
      });
    }, { threshold: 0.4 });
    if (counters.length) {
      const statsWrap = document.querySelector('.stats');
      if (statsWrap) statsObs.observe(statsWrap);
    }
  }
})();
