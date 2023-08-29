function updateClock() {
    const now = new Date();

    const year = now.getFullYear();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    const dayOfWeek = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'][now.getDay()];
    const hours = now.getHours();
    const minutes = now.getMinutes();
    const seconds = now.getSeconds();

    const currentDateElement = document.querySelector('.current-date');
    const currentTimeElement = document.querySelector('.current-time');

    currentDateElement.textContent = `${year}年${month}月${day}日  ${dayOfWeek}`;
    currentTimeElement.textContent = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
}

updateClock();
setInterval(updateClock, 1000);