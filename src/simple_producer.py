from kafka import KafkaProducer
import json
import time
import os
def simple_producer():    
    bootstrap_servers = os.getenv("BOOTSTRAP_SERVERS", "localhost:9092")
    producer = KafkaProducer(
        bootstrap_servers=[bootstrap_servers],
        value_serializer=lambda v: json.dumps(v).encode('utf-8')
    )
    
    # Envia 10 mensagens
    for i in range(10):
        message = {
            'id': i,
            'message': f'Mensagem número {i}',
            'timestamp': time.time()
        }
        
        producer.send('meu-topico', message)
        print(f'Enviada mensagem {i}')
        time.sleep(1)
    
    producer.close()

if __name__ == "__main__":
    simple_producer()
    