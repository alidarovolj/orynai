#!/bin/bash

echo "🚀 Starting app with performance timing..."
echo "================================================"
echo ""

# Запускаем приложение и фильтруем логи
flutter run 2>&1 | grep -E "(═══|🚀|✅|⚠️|❌|⏳|🔄|🏠|🎨|🏗️|ms)" --line-buffered | tee app_timing.log

echo ""
echo "================================================"
echo "Logs saved to app_timing.log"
