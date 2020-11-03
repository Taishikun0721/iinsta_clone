const input = document.querySelector('.input-comment-body');
const inputCounter = document.querySelector('#comment-count');
const submitBtn = document.querySelector('#comment-submit');

function countLength(limit) {
    var count = input.value.length
    if (count === 0) {
        inputCounter.innerHTML = "";
    } else if (count <= this.limit) {
        inputCounter.innerHTML = `${count}文字`
        submitBtn.classList.remove('disabled');
    } else {
        inputCounter.innerHTML = `${this.limit}文字以上は入力できません`;
        submitBtn.classList.add('disabled');
    }
}

input.addEventListener('keyup', {limit: 1000, handleEvent: countLength})