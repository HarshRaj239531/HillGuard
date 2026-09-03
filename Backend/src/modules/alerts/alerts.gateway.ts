import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class AlertsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  private readonly logger = new Logger(AlertsGateway.name);

  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    this.logger.log(`Client connected to real-time disaster mesh: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('ping')
  handlePing(client: Socket, data: any) {
    return { event: 'pong', data: { timestamp: new Date().toISOString() } };
  }

  broadcastHazardUpdate(event: string, payload: any) {
    if (this.server) {
      this.server.emit(event, payload);
    }
  }
}
