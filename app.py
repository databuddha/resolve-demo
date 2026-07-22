from flask import Flask, jsonify
import time
import random

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.instrumentation.flask import FlaskInstrumentor

resource = Resource(attributes={"service.name": "order-service"})
provider = TracerProvider(resource=resource)
provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)

app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)

@app.route("/health")
def health():
    return jsonify(status="ok")

@app.route("/orders")
def orders():
    with tracer.start_as_current_span("fetch-orders-from-db"):
        time.sleep(random.uniform(0.05, 1.5))
    return jsonify(orders=[
        {"id": 1, "item": "widget"},
        {"id": 2, "item": "gadget"}
    ])

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)