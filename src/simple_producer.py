from kafka import KafkaProducer
import json
import time

def simple_producer():
    producer = KafkaProducer(
        bootstrap_servers=['localhost:9092'],
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
    