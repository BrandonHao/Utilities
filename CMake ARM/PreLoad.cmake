# Force cmake to use Unix Makefiles
# Probably not needed on Linux but Windows will default to MSVC
set (CMAKE_GENERATOR "Unix Makefiles" CACHE INTERNAL "" FORCE)
