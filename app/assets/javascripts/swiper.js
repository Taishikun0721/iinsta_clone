var mySwiper = new Swiper ('.swiper-container', {
    loop: true,
    pagination: {
        el: '.swiper-pagination',
    },
    autoplay: {
        delay: 3000,
    },
})
// autoplayを付けてみた。初期化用のファイルでこのファイルはswiper使用には必須。
