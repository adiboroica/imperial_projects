from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from ..serializers import NewCoachUserSerializer, NewOrganiserUserSerializer


class HelloView(APIView):
    def get(self, request, format=None):
        return Response("Hello {0}!".format(request.user))


class CreateCoachUser(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request, format=None):
        serializer = NewCoachUserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "test"})
        return Response(
            {"error": True, "error_msg": serializer.errors},
            status=400,
        )


class CreateOrganiserUser(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request, format=None):
        serializer = NewOrganiserUserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "test"})
        return Response(
            {"error": True, "error_msg": serializer.errors},
            status=400,
        )
