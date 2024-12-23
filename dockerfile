# Use official Python runtime as a parent image
FROM python:3.8-slim

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container
COPY . /app

# Install the Flask web framework
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 80 to be accessed externally
EXPOSE 80

# Run the app
CMD ["python", "app.py"]
