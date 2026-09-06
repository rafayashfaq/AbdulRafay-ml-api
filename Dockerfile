FROM python:3.12-slim

ARG APP_VERSION
ARG GIT_COMMIT
ARG BUILD_DATE

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY tests/ ./tests/
COPY VERSION .

LABEL org.opencontainers.image.title="student-ml-api"
LABEL org.opencontainers.image.description="Student ML inference API"
LABEL org.opencontainers.image.version="${APP_VERSION}"
LABEL org.opencontainers.image.revision="${GIT_COMMIT}"
LABEL org.opencontainers.image.source="https://github.com/rafayashfaq/AbdulRafay-ml-api"
LABEL org.opencontainers.image.created="${BUILD_DATE}"

EXPOSE 5000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5000"]
