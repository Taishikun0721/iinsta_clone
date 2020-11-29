//= require jquery3
//= require popper
//= require rails-ujs
//= require bootstrap-material-design/dist/js/bootstrap-material-design.js

function previewFileWithId(selector) {
    const preview = document.querySelector('#preview');
    const loadedFile = document.querySelector('#loaded_file').files[0];
    const reader = new FileReader();

    reader.addEventListener('load', () => {
        preview.src = reader.result;
    }, false)

    if (loadedFile) {
        reader.readAsDataURL(loadedFile);
    } else {
        selector.src = "";
    }
}

// 練習と思ってjsに書き換えてみまたと言ってもあんまり変わっていないんですが・・・
// jqueryあんまり書いた事ないんですが覚えておいた方がいいですか？