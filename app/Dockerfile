FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Expose the Flask port
EXPOSE 8080

# Set environment variables
ENV PORT=8080
ENV ENV=production

# Run the app with Gunicorn (recommended for production)
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8080", "app:app"]

