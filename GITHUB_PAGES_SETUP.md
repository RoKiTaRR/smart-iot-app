# GitHub Pages Deployment Guide

## Конфігурація проекту для GitHub Pages

Проект успішно підготовлено для розміщення на GitHub Pages. Ось що було зроблено:

### ✅ Внесені зміни:

1. **`web/index.html`** - оновлено базовий href на `/`
2. **`docs/404.html`** - створено для правильної маршрутизації Single Page Application
3. **`docs/_redirects`** - додано правила перенаправлення
4. **`.github/workflows/deploy.yml`** - автоматична збірка та розгортання
5. **`web/_redirects`** - додано файл маршрутизації

### 📋 Кроки для розгортання:

1. **Переконайтесь, що використовуєте гілку `main`** як основну гілку
   ```bash
   git branch -M main
   ```

2. **Налаштування GitHub Pages в репозиторії:**
   - Перейдіть на GitHub → Settings → Pages
   - Встановіть Source на `gh-pages` (буде автоматично створено при першому запуску)
   - Build and deployment: Deploy from a branch
   - Гілка: `gh-pages` + `/ (root)`

3. **Перший push запустить автоматичну збірку:**
   ```bash
   git add .
   git commit -m "Configure GitHub Pages deployment"
   git push origin main
   ```

4. **Перевірте GitHub Actions:**
   - Перейдіть на GitHub → Actions
   - Очікуйте завершення workflow "Deploy to GitHub Pages"

5. **Завантажена сторінка буде доступна за адресою:**
   - `https://YOUR_USERNAME.github.io/smart_iot_app/`

### ⚙️ GitHub Actions Workflow

Workflow автоматично:
- Збирає Flutter web додаток при push на `main`
- Розгортує на `gh-pages` гілку
- Публікує на GitHub Pages

Якщо потрібно змінити шлях розгортання, відредагуйте `.github/workflows/deploy.yml` та змініть `--base-href`.

### 🔧 Налаштування для кастомного домену (опціонально)

Якщо у вас є власний домен:
1. Додайте CNAME запись у DNS провайдера
2. В GitHub Pages налаштуваннях введіть домен
3. В `.github/workflows/deploy.yml` змініть `cname: false` на `cname: true`

### 📌 Важливо!

- Запевніться, що **`docs/`** папка комітиться у репозиторій (вона контролюється маршрутизацією)
- **`.gitignore`** не повинен ігнорувати `/docs/` або `.github/workflows/`
- Перший деплой може зайнути 1-5 хвилин

---

Проект готовий до розгортання! 🚀
