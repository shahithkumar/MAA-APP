from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from .serializers import (
    ChatRequestSerializer, ChatResponseSerializer, 
    ChatSessionSerializer, ChatMessageSerializer
)
from .models import ChatSession, ChatMessage
from .orchestrator import process_message
from .logger import log_chat
from .doc_engine import query_documents

@api_view(['GET'])
def root(request):
    return Response({"message": "Welcome to MAA 2.0 (Cognitive Architecture)"})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def chat_view(request):
    serializer = ChatRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    session_id = serializer.validated_data['session_id']
    query = serializer.validated_data['query']
    mode = serializer.validated_data.get('mode', 'friend')
    
    # --- PERSISTENCE LAYER ---
    # 1. Get or Create Session
    chat_session, created = ChatSession.objects.get_or_create(
        session_id=session_id,
        defaults={'mode': mode, 'user': request.user}
    )
    
    # Ensure user is linked if it was created without user (legacy/transitional)
    if not chat_session.user:
        chat_session.user = request.user
        chat_session.save()

    # Update title if new (simple heuristic)
    if created or not chat_session.title:
        chat_session.title = query[:50] + "..."
        chat_session.save()
    
    # 2. Save User Message
    ChatMessage.objects.create(
        session=chat_session, 
        sender='user', 
        content=query
    )

    # 7-LAYER SYSTEM CALL
    response_text = process_message(session_id, query, mode=mode)
    
    # 3. Save AI Message
    ChatMessage.objects.create(
        session=chat_session, 
        sender='ai', 
        content=response_text
    )
    
    # Log (legacy redundant but safe to keep)
    log_chat(session_id, query, response_text, False)
    
    return Response({"response": response_text})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def chat_history_view(request):
    """
    Get list of chat sessions, optionally filtered by mode.
    Usage: /api/chat/history/?mode=friend
    """
    mode = request.query_params.get('mode')
    sessions = ChatSession.objects.filter(user=request.user).order_by('-updated_at')
    
    if mode:
        sessions = sessions.filter(mode=mode)
        
    serializer = ChatSessionSerializer(sessions, many=True)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def session_messages_view(request, session_id):
    """
    Get all messages for a specific session.
    """
    session = get_object_or_404(ChatSession, session_id=session_id, user=request.user)
    messages = session.messages.all()
    serializer = ChatMessageSerializer(messages, many=True)
    return Response(serializer.data)

@api_view(['POST'])
def doc_chat_view(request):
    serializer = ChatRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    session_id = serializer.validated_data['session_id']
    query = serializer.validated_data['query']
    response = query_documents(query)
    log_chat(session_id, query, response, False)
    return Response({"response": response})
