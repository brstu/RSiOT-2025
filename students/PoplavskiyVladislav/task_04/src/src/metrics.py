from prometheus_client import Counter, Histogram, Gauge
import os

# Префикс метрик из переменной окружения
PREFIX = os.getenv('METRICS_PREFIX', 'app17_')

# Счетчик HTTP запросов
REQUEST_COUNTER = Counter(
    f'{PREFIX}http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

# Гистограмма времени выполнения запросов
REQUEST_DURATION = Histogram(
    f'{PREFIX}http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint'],
    buckets=[0.05, 0.1, 0.2, 0.3, 0.5, 1.0, 2.0, 5.0]
)

# Gauge для отслеживания ошибок
ERROR_GAUGE = Gauge(
    f'{PREFIX}http_errors_total',
    'Total HTTP errors'
)

# Gauge для отслеживания активных запросов
ACTIVE_REQUESTS = Gauge(
    f'{PREFIX}http_active_requests',
    'Active HTTP requests'
)

# Gauge для uptime приложения
UPTIME = Gauge(
    f'{PREFIX}uptime_seconds',
    'Application uptime in seconds'
)