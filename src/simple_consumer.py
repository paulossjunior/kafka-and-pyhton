from kafka import KafkaConsumer
import json

def simple_consumer():
    consumer = KafkaConsumer(
        'meu-topico',
        bootstrap_servers=['localhost:9092'],
        group_id='meu-grupo-consumer',
        value_deserializer=lambda m: json.loads(m.decode('utf-8')),
        auto_offset_reset='earliest'  # Lê desde o início
    )
    
    print("Aguardando mensagens... (Ctrl+C para sair)")
    
    try:
        for message in consumer:
            print(f"Recebido: {message.value}")
            
            # Aqui você processa sua mensagem
            # Exemplo: salvar no banco, enviar email, etc.
            
    except KeyboardInterrupt:
        print("Consumer interrompido")
    finally:
        consumer.close()


if __name__ == "__main__":
    simple_consumer()
    