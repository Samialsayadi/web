""" This module contains the routers for the FastAPI application. """

from routers.dynamic import router as dynamic
from routers.index import router as index

__all__ = ["dynamic", "index"]
