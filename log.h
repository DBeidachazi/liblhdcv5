#pragma once

#include <stdio.h>

#ifndef LOG_TAG
#define LOG_TAG "lhdcv5"
#endif

#define ALOGE(...) do { fprintf(stderr, LOG_TAG ": E: " __VA_ARGS__); fputc('\n', stderr); } while (0)
#define ALOGW(...) do { fprintf(stderr, LOG_TAG ": W: " __VA_ARGS__); fputc('\n', stderr); } while (0)
#define ALOGI(...) do { fprintf(stderr, LOG_TAG ": I: " __VA_ARGS__); fputc('\n', stderr); } while (0)
#define ALOGD(...) do { fprintf(stderr, LOG_TAG ": D: " __VA_ARGS__); fputc('\n', stderr); } while (0)
