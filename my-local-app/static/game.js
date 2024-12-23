document.addEventListener("DOMContentLoaded", () => {
    const canvas = document.getElementById("gameCanvas");
    const ctx = canvas.getContext("2d");

    const gridSize = 20;
    const canvasSize = 600; // Increased canvas size
    let score = 0;
    let snake = [{ x: 160, y: 160 }];
    let food = { x: 100, y: 100 };
    let dx = gridSize;
    let dy = 0;
    let gameOver = false;
    let gameStarted = false;
    let gameSpeed = 100;  // Default speed for the game (easy)

    // Set the canvas size
    canvas.width = canvasSize;
    canvas.height = canvasSize;

    // Draw the snake (now just simple blocks)
    function drawSnake() {
        snake.forEach((segment) => {
            ctx.fillStyle = "green";
            ctx.fillRect(segment.x, segment.y, gridSize, gridSize);
        });
    }

    // Draw the food
    function drawFood() {
        ctx.fillStyle = "red";
        ctx.fillRect(food.x, food.y, gridSize, gridSize);
    }

    // Draw the grid background
    function drawGrid() {
        ctx.strokeStyle = "lightgreen";
        ctx.lineWidth = 1;
        for (let x = 0; x < canvas.width; x += gridSize) {
            for (let y = 0; y < canvas.height; y += gridSize) {
                ctx.strokeRect(x, y, gridSize, gridSize);
            }
        }
    }

    // Move the snake
    function moveSnake() {
        const head = { x: snake[0].x + dx, y: snake[0].y + dy };

        // Wrap around the screen
        if (head.x < 0) head.x = canvas.width - gridSize;
        if (head.x >= canvas.width) head.x = 0;
        if (head.y < 0) head.y = canvas.height - gridSize;
        if (head.y >= canvas.height) head.y = 0;

        snake.unshift(head); // Add the new head at the front of the array

        if (head.x === food.x && head.y === food.y) {
            score += 10;
            placeFood(); // Place new food
        } else {
            snake.pop(); // Remove the last segment to maintain the snake's length
        }
    }

    // Place food at a random position
    function placeFood() {
        food.x = Math.floor(Math.random() * (canvas.width / gridSize)) * gridSize;
        food.y = Math.floor(Math.random() * (canvas.height / gridSize)) * gridSize;
    }

    // Update the game
    function update() {
        if (gameOver) {
            alert(`Game Over! Your score is ${score}`);
            resetGame();
            return;
        }

        moveSnake();
        checkCollisions();
        drawGame();
    }

    // Check for self-collision (not wall collision)
    function checkCollisions() {
        const head = snake[0];

        // Self-collision (snake colliding with itself)
        for (let i = 1; i < snake.length; i++) {
            if (head.x === snake[i].x && head.y === snake[i].y) {
                gameOver = true;
            }
        }
    }

    // Draw the game (snake, food, and score)
    function drawGame() {
        ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear the canvas
        drawGrid();  // Draw the grid
        drawSnake();
        drawFood();
        document.getElementById("score").textContent = `Score: ${score}`;
    }

    // Listen for keyboard input (Arrow keys to move)
    document.addEventListener("keydown", (e) => {
        if (e.key === "ArrowUp" && dy === 0) {
            dx = 0;
            dy = -gridSize;
        } else if (e.key === "ArrowDown" && dy === 0) {
            dx = 0;
            dy = gridSize;
        } else if (e.key === "ArrowLeft" && dx === 0) {
            dx = -gridSize;
            dy = 0;
        } else if (e.key === "ArrowRight" && dx === 0) {
            dx = gridSize;
            dy = 0;
        }
    });

    // Reset the game
    function resetGame() {
        score = 0;
        snake = [{ x: 160, y: 160 }];
        dx = gridSize;
        dy = 0;
        gameOver = false;
        gameStarted = false;
        placeFood();
        document.getElementById("startButton").disabled = false;  // Re-enable start button
    }

    // Start the game when button is clicked
    document.getElementById("startButton").addEventListener("click", () => {
        if (!gameStarted) {
            gameStarted = true;
            setInterval(update, gameSpeed); // Start the game loop
        }
    });

    // Set difficulty (Easy or Hard)
    document.getElementById("easyButton").addEventListener("click", () => {
        gameSpeed = 150;  // Slow speed for easy
        resetGame();
        document.getElementById("startButton").disabled = false;
    });

    document.getElementById("hardButton").addEventListener("click", () => {
        gameSpeed = 50;  // Fast speed for hard
        resetGame();
        document.getElementById("startButton").disabled = false;
    });

    // Place initial food
    placeFood();
});

