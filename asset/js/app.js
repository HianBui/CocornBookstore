
// SCROLL TO TOP
window.addEventListener('scroll', () => {

    var scrollToTop = document.getElementById('scrollToTop');

    let scrollY = window.scrollY;
    if(scrollY > 0){
        scrollToTop.classList.add('scroll');

    }else{
        scrollToTop.classList.remove('scroll');
    }
});

// STICKY NAVIGATION (POSITION FIXED)
const nav = document.querySelector(".navigation");
const sentinel = document.createElement("div");
sentinel.style.height = "1px";
nav.before(sentinel);

const observer = new IntersectionObserver(
    (entries) => {
    if (!entries[0].isIntersecting) {
        nav.classList.add("fixed");
    } else {
        nav.classList.remove("fixed");
    }
    },
    { threshold: [0] }
);

observer.observe(sentinel);

// Tab
const tabs = document.querySelectorAll('.tab');
const contents = document.querySelectorAll('.tab-content');

tabs.forEach(tab => {
  tab.addEventListener('click', () => {
    tabs.forEach(t => t.classList.remove('active'));
    contents.forEach(c => c.classList.remove('active'));

    tab.classList.add('active');
    document.getElementById(tab.dataset.tab).classList.add('active');
  });
});
