const spark_container = document.getElementById('spark-container');
const sparks = document.getElementsByClassName('spark');

// Increase the number of sparks
for (let i = 0; i < 50; i++) {
    const spark = document.createElement('div');
    spark.className = 'spark';
    spark_container.appendChild(spark);
}

for (spark of sparks) {
    spark.style.rotate = Math.floor(Math.random() * 360) + 'deg';
    spark.style.animationDelay = Math.floor(Math.random() * 5000) + 'ms';
}