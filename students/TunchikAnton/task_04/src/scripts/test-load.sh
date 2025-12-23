#!/bin/bash
echo "Generating load for monitoring app..."
for i in {1..1000}; do
  curl -s http://localhost:8080/ > /dev/null
  if [ $(($i % 10)) -eq 0 ]; then
    curl -s http://localhost:8080/api/data > /dev/null
  fi
  if [ $(($i % 50)) -eq 0 ]; then
    echo "Requests: $i"
  fi
done
echo "Load test completed"