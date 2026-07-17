<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AgriConnect - Platform Pertanian Digital</title>
  <meta name="description" content="AgriConnect adalah platform digital terbaik untuk komoditas Beras dan Jagung. Menghubungkan petani lokal dengan pembeli secara langsung untuk rantai pasok yang lebih transparan dan efisien.">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400..900;1,400..900&family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&display=swap" rel="stylesheet">
  <style>
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}
:root {
  --primary-color: #116523;
  --primary-light: #177d42;
  --accent-color: #4cdf2b;
  --mint-bg: #f1fff8;
  --mint-accent: #e8ffe0;
  --dark-text: #2c3e2e;
  --light-text: #ffffff;
  --gray-text: #7c8e7e;
  --card-shadow: 0 10px 30px rgba(17, 101, 35, 0.08);
  --hover-shadow: 0 20px 40px rgba(17, 101, 35, 0.15);
  --bg-dark: #114220;
  --bg-light: #4cdf2b;
  --glass-bg: rgba(255, 255, 255, 0.15);
  --glass-border: rgba(255, 255, 255, 0.3);
  --glass-blur: blur(15px);
  --glass-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}
html {
  scroll-behavior: smooth;
  font-family: 'Roboto', sans-serif;
  color: var(--dark-text);
  background-color: var(--bg-dark);
}
body {
  overflow-x: hidden;
  background: radial-gradient(150% 100% at 50% 0%, #126524 0%, #177E43 22%, #4AA370 51%, #73CA98 70%, #C4F5D9 84%, #FFFFFF 97%);
  background-attachment: fixed;
  color: var(--light-text);
  position: relative;
}
.blob {
  position: fixed;
  filter: blur(80px);
  z-index: -1;
  opacity: 0.6;
  animation: float-blob 20s infinite ease-in-out;
}
.blob-1 {
  top: -10%; left: -10%;
  width: 50vw; height: 50vw;
  background-color: var(--bg-light);
  border-radius: 40% 60% 70% 30% / 40% 50% 60% 50%;
}
.blob-2 {
  bottom: -20%; right: -10%;
  width: 60vw; height: 60vw;
  background-color: #0b3d17;
  border-radius: 60% 40% 30% 70% / 50% 60% 40% 50%;
  animation-direction: reverse;
}
.blob-3 {
  top: 40%; left: 20%;
  width: 40vw; height: 40vw;
  background-color: #279e51;
  border-radius: 30% 70% 50% 50% / 50% 40% 60% 50%;
  animation-duration: 25s;
}
@keyframes float-blob {
  0%, 100% { transform: translate(0, 0) scale(1) rotate(0deg); }
  33% { transform: translate(5%, 10%) scale(1.1) rotate(10deg); }
  66% { transform: translate(-5%, -5%) scale(0.9) rotate(-10deg); }
}
h1, h2, h3, .section-title { font-family: 'Playfair Display', serif; }
section { padding: 100px 5% 80px; position: relative; }
.section-tag {
  display: inline-block;
  font-size: 14px; font-weight: 700;
  color: #177E43; letter-spacing: 2px;
  margin-bottom: 12px; text-transform: uppercase;
}
.section-tag.centered { text-align: center; display: block; width: 100%; }
.section-title {
  font-size: 40px; font-weight: 800;
  color: var(--light-text); line-height: 1.2; margin-bottom: 24px;
}
.section-title.centered { text-align: center; margin-bottom: 16px; }
.section-subtitle.centered {
  text-align: center; font-size: 18px;
  color: rgba(0,0,0,0); max-width: 700px;
  margin: 0 auto 50px; line-height: 1.6;
}
.btn-primary {
  display: inline-block; background-color: #126524;
  color: #ffffff; font-weight: 700; font-size: 16px;
  padding: 14px 28px; border-radius: 50px;
  text-decoration: none; transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(18, 101, 36, 0.3);
}
.btn-primary:hover { background-color: #0f541e; }
.btn-secondary {
  display: inline-block; background-color: rgba(255,255,255,0.15);
  color: #ffffff; font-weight: 700; font-size: 16px;
  padding: 14px 28px; border: 1px solid rgba(255,255,255,0.5);
  border-radius: 50px; text-decoration: none;
  backdrop-filter: blur(10px); transition: all 0.3s ease;
}
.btn-secondary:hover { background-color: rgba(255,255,255,0.25); }
.navbar-container {
  position: fixed; top: 20px; left: 0;
  width: 100%; z-index: 1000; padding: 0 5%;
}
.navbar-wrapper {
  max-width: 1200px; margin: 0 auto;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.5);
  border-radius: 50px; display: flex;
  justify-content: space-between; align-items: center;
  padding: 10px 24px; box-shadow: 0 8px 32px 0 rgba(0,0,0,0.15);
}
.navbar-logo img { height: 40px; display: block; }
.navbar-menu { display: flex; gap: 24px; }
.navbar-menu a {
  color: var(--primary-color); text-decoration: none;
  font-size: 15px; font-weight: 700; transition: all 0.3s ease;
  padding: 6px 0; position: relative;
}
.navbar-menu a::after {
  content: ''; position: absolute; bottom: 0; left: 0;
  width: 0; height: 2px; background-color: var(--primary-color);
  transition: width 0.3s ease;
}
.navbar-menu a:hover, .navbar-menu a.active { color: var(--primary-light); }
.navbar-menu a:hover::after, .navbar-menu a.active::after { width: 100%; }
.btn-navbar {
  display: inline-block; background-color: #126524;
  color: #ffffff; font-weight: 600; font-size: 14px;
  padding: 8px 24px; border-radius: 50px;
  text-decoration: none; transition: all 0.3s ease; border: none;
}
.btn-navbar:hover {
  background-color: var(--primary-light);
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(23,125,66,0.2);
}
.hero-section {
  min-height: 100vh; background: transparent;
  position: relative; display: flex; align-items: center;
  padding-top: 140px; padding-bottom: 80px; overflow: hidden;
}
.hero-section::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
  background-image: conic-gradient(rgba(255,255,255,0.03) 90deg, transparent 90deg 180deg, rgba(255,255,255,0.03) 180deg 270deg, transparent 270deg);
  background-size: 100px 100px; z-index: 1;
}
.hero-wrapper {
  max-width: 1200px; margin: 0 auto;
  display: grid; grid-template-columns: 1fr 1fr;
  align-items: center; gap: 30px; width: 100%;
  position: relative; z-index: 2;
}
.hero-content { color: var(--light-text); }
.badge-platform {
  display: inline-flex; align-items: center; gap: 8px;
  background: rgba(255,255,255,0.15); backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,0.2);
  padding: 6px 16px; border-radius: 50px;
  font-size: 12px; font-weight: 700; letter-spacing: 1px; margin-bottom: 24px;
}
@keyframes pulse-dot {
  0% { opacity: 1; transform: scale(1); box-shadow: 0 0 10px var(--accent-color); }
  50% { opacity: 0.4; transform: scale(0.8); box-shadow: 0 0 2px var(--accent-color); }
  100% { opacity: 1; transform: scale(1); box-shadow: 0 0 10px var(--accent-color); }
}
.dot-green {
  width: 8px; height: 8px; background-color: var(--accent-color);
  border-radius: 50%; display: inline-block;
  box-shadow: 0 0 10px var(--accent-color);
  animation: pulse-dot 1.5s infinite ease-in-out;
}
.hero-title {
  font-size: 54px; font-weight: 800; line-height: 1.15;
  margin-bottom: 20px; color: #ffffff;
  text-shadow: 0 2px 15px rgba(0,0,0,0.4);
}
.hero-title .highlight { position: relative; display: inline-block; color: #ffffff; }
.hero-title .highlight::after {
  content: ''; position: absolute; left: 0; bottom: 0px;
  width: 100%; height: 4px; background-color: var(--accent-color);
}
.hero-desc {
  font-size: 18px; line-height: 1.6; color: #ffffff; font-weight: 500;
  margin-bottom: 40px; max-width: 650px;
  text-shadow: 0 1px 8px rgba(0,0,0,0.3);
}
.hero-buttons { display: flex; gap: 20px; }
.hero-mockup {
  display: flex; justify-content: center;
  align-items: center; gap: 15px;
  position: relative;
  width: 100%;
}
/* CSS Mockup Frame Premium */
.hero-mockup .phone-container {
  position: relative;
  max-width: 170px; width: 100%;
  padding: 6px;
  background: linear-gradient(145deg, #ffffff, #e6e6e6);
  border-radius: 34px;
  box-shadow: 
    0 25px 50px -12px rgba(0,0,0,0.25), 
    inset 0 2px 4px rgba(255,255,255,0.8), 
    inset 0 -2px 6px rgba(0,0,0,0.1),
    0 0 0 1px rgba(255,255,255,0.4);
  transition: all 0.5s cubic-bezier(0.25, 0.8, 0.25, 1);
  cursor: pointer;
  z-index: 2;
  animation: float 6s ease-in-out infinite;
}
.hero-mockup .phone-container::after {
  /* Notch yang lebih kecil dan elegan */
  content: '';
  position: absolute;
  top: 6px; left: 50%;
  transform: translateX(-50%);
  width: 30%; height: 12px;
  background: linear-gradient(to bottom, #ffffff, #f0f0f0);
  border-bottom-left-radius: 8px;
  border-bottom-right-radius: 8px;
  z-index: 5;
}
.hero-mockup .phone-container::before {
  /* Lensa kamera depan */
  content: '';
  position: absolute;
  top: 9px; left: 50%;
  transform: translateX(-50%);
  width: 4px; height: 4px;
  background-color: #1a1a1a;
  border-radius: 50%;
  z-index: 6;
  box-shadow: inset 0 1px 1px rgba(255,255,255,0.2);
}
.hero-mockup .phone-container:nth-child(1) { animation-delay: 0s; }
.hero-mockup .phone-container:nth-child(2) { animation-delay: 1s; }
.hero-mockup .phone-container:nth-child(3) { animation-delay: 2s; }

.hero-mockup .phone-container img {
  width: 100%; height: auto; 
  border-radius: 28px;
  display: block;
  border: 1px solid rgba(0,0,0,0.05);
}

.hero-mockup .phone-container:hover {
  transform: translateY(-15px) scale(1.05);
  z-index: 10;
  filter: drop-shadow(0 20px 40px rgba(0,0,0,0.3));
}

.phone-label {
  position: absolute;
  bottom: -35px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(255,255,255,0.2);
  backdrop-filter: blur(10px);
  padding: 6px 14px;
  border-radius: 15px;
  color: #fff;
  font-size: 13px;
  font-weight: 700;
  white-space: nowrap;
  border: 1px solid rgba(255,255,255,0.5);
  box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}
@keyframes float {
  0% { transform: translateY(0px); }
  50% { transform: translateY(-15px); }
  100% { transform: translateY(0px); }
}
.about-section { background-color: #ffffff; }
.about-wrapper {
  max-width: 1200px; margin: 0 auto;
  display: grid; grid-template-columns: 1fr 1fr;
  gap: 60px; align-items: center;
}
.about-section .section-title { color: var(--dark-text); text-align: left; }
.about-section .section-tag { color: #177E43; text-align: left; display: inline-block; }
.about-desc { font-size: 17px; line-height: 1.7; color: var(--gray-text); margin-bottom: 30px; }
.about-checklist { list-style: none; display: flex; flex-direction: column; gap: 24px; }
.about-checklist li { display: flex; gap: 16px; align-items: flex-start; }
.check-icon { width: 28px; height: 28px; flex-shrink: 0; }
.about-checklist strong { display: block; font-size: 18px; color: var(--dark-text); margin-bottom: 4px; }
.about-checklist p { color: var(--gray-text); font-size: 15px; line-height: 1.5; }
.about-commodity { display: flex; justify-content: center; width: 100%; }
.commodity-card {
  background-color: #fbfcfa; border-radius: 20px; padding: 40px;
  width: 100%; max-width: 700px; box-shadow: 0 8px 30px rgba(0,0,0,0.1);
  position: relative; overflow: hidden; transition: all 0.3s ease;
}
.commodity-card:hover { transform: translateY(-5px); box-shadow: var(--hover-shadow); }
.commodity-icon {
  height: 120px; display: flex; justify-content: center;
  align-items: center; margin-bottom: 8px; position: relative;
}
.combined-icon { height: 160px; width: auto; object-fit: contain; transform: translate(18px, 0); }
.commodity-card-title { font-size: 34px; color: var(--primary-color); text-align: center; margin-bottom: 16px; font-weight: 800; }
.commodity-card-desc { text-align: center; font-size: 14px; line-height: 1.6; color: var(--gray-text); margin-bottom: 30px; }
.commodity-table { display: flex; flex-direction: column; gap: 12px; }
.table-row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid rgba(114,202,152,0.3); }
.table-row:last-child { border-bottom: none; }
.commodity-name { font-weight: 500; color: var(--dark-text); }
.commodity-price { font-weight: 700; color: var(--primary-light); }
.features-section { background: linear-gradient(180deg, #ffffff 0%, #b8e0c6 15%, #b8e0c6 85%, #ffffff 100%); }
.features-section .section-title { color: var(--dark-text); }
.features-header { margin-bottom: 40px; }
.features-grid {
  max-width: 1100px; margin: 0 auto;
  display: grid; grid-template-columns: repeat(2, 1fr); gap: 30px;
}
.feature-card {
  background: rgba(255,255,255,0.15); backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px); border-radius: 20px; padding: 35px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.1); transition: all 0.3s ease;
  border: 1px solid rgba(255,255,255,0.5);
}
.feature-card:hover { transform: translateY(-8px); box-shadow: 0 15px 40px rgba(0,0,0,0.2); }
.feature-icon-wrapper {
  width: 60px; height: 60px; background-color: rgba(255,255,255,0.2);
  border-radius: 15px; display: flex; justify-content: center; align-items: center;
  margin-bottom: 24px; border: 1px solid rgba(255,255,255,0.4);
}
.feature-emoji { font-size: 32px; }
.feature-card-title { font-size: 20px; font-weight: 800; color: var(--primary-color); margin-bottom: 12px; font-family: 'Roboto', sans-serif; }
.feature-card-desc { font-size: 15px; line-height: 1.6; color: var(--dark-text); font-weight: 500; }
.workflow-section {
  background-color: #ffffff;
  background-image: radial-gradient(circle at 55% 50%, rgba(81,221,50,0.655) 0%, rgba(76,223,43,0.05) 40%, transparent 70%);
}
.workflow-section .section-title { color: var(--dark-text); }
.workflow-section .section-tag { color: #177E43; }
.workflow-header { margin-bottom: 40px; }
.workflow-grid { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 40px; }
.workflow-card { background-color: transparent; padding: 10px 0; position: relative; transition: all 0.3s ease; }
.workflow-number { font-family: 'Playfair Display', serif; font-size: 64px; font-weight: 800; color: #c3eed6; line-height: 1; margin-bottom: 12px; }
.workflow-card-title { font-size: 20px; font-weight: 700; color: var(--dark-text); margin-bottom: 12px; font-family: 'Roboto', sans-serif; }
.workflow-card-desc { font-size: 15px; line-height: 1.6; color: var(--gray-text); }
.team-section { background-color: #ffffff; }
.team-section .section-title { color: var(--dark-text); }
.team-section .section-tag { color: #177E43; }
.team-header { margin-bottom: 50px; }
.team-container { max-width: 1200px; margin: 0 auto; display: flex; flex-direction: column; gap: 50px; }
.team-row { display: flex; justify-content: center; gap: 60px; flex-wrap: wrap; }
.team-member { display: flex; flex-direction: column; align-items: center; width: 250px; }
.avatar-wrapper { position: relative; width: 200px; height: 200px; margin-bottom: 30px; }
.avatar-glow {
  position: absolute; top: 0; left: 0; right: 0; bottom: -20px;
  background: var(--primary-color); border-radius: 50%; z-index: 0;
}
.team-member:hover .avatar-glow { opacity: 0.35; filter: blur(8px); transform: scale(1.05); }
.avatar-img {
  width: 100%; height: 100%; border-radius: 50%; object-fit: cover;
  border: 4px solid #ffffff; position: relative; z-index: 1;
  box-shadow: 0 10px 20px rgba(0,0,0,0.1);
}
.avatar-placeholder {
  width: 100%; height: 100%; border-radius: 50%;
  background: var(--primary-color); border: 4px solid #ffffff;
  position: relative; z-index: 1; box-shadow: 0 10px 20px rgba(0,0,0,0.1);
}
.role-badge {
  position: absolute; bottom: -15px; left: 50%; transform: translateX(-50%);
  background: linear-gradient(135deg, rgba(255,255,255,0.85), rgba(255,255,255,0.4));
  backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);
  color: #000000; font-size: 14px; font-weight: 700;
  padding: 8px 24px; border-radius: 50px; white-space: nowrap;
  box-shadow: 0 8px 20px rgba(0,0,0,0.1), inset 0 2px 5px rgba(255,255,255,0.5);
  border: 1px solid rgba(255,255,255,0.6); border-bottom: 1px solid rgba(0,0,0,0.1); z-index: 2;
}
.member-name { font-size: 16px; font-weight: 700; color: var(--primary-color); text-align: center; margin-top: 8px; margin-bottom: 4px; }
.member-npm { font-size: 13px; color: var(--gray-text); font-weight: 400; }
.faq-section { background: linear-gradient(180deg, #ffffff 0%, #b8e0c6 15%, #b8e0c6 85%, #ffffff 100%); }
.faq-section .section-title { color: var(--dark-text); }
.faq-header { margin-bottom: 40px; }
.faq-list { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 20px; }
.faq-item {
  background: rgba(255,255,255,0.15); backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px); border-radius: 15px; padding: 24px 30px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.1); border: 1px solid rgba(255,255,255,0.5);
  transition: all 0.3s ease;
}
.faq-item:hover { transform: translateY(-3px); box-shadow: var(--hover-shadow); }
.faq-question { font-size: 18px; font-weight: 700; color: var(--dark-text); margin-bottom: 12px; font-family: 'Roboto', sans-serif; }
.faq-answer { font-size: 15px; line-height: 1.6; color: var(--gray-text); }
.cta-section {
  padding: 100px 5%; position: relative;
  display: flex; justify-content: center; align-items: center;
  overflow: hidden; text-align: center;
}
.cta-background {
  position: absolute; top: 0; left: 0; width: 100%; height: 100%;
  background-size: cover; background-position: center; z-index: 0;
  filter: blur(4px); transform: scale(1.02);
}
.cta-overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.4); z-index: 1; }
.cta-content { position: relative; z-index: 2; color: var(--light-text); max-width: 800px; }
.cta-title { font-size: 44px; font-weight: 800; margin-bottom: 20px; }
.cta-desc { font-size: 18px; line-height: 1.6; opacity: 0.9; margin-bottom: 35px; }
.btn-cta-download {
  display: inline-block; background-color: #ffffff; color: var(--primary-color);
  font-weight: 700; font-size: 16px; padding: 16px 36px; border-radius: 10px;
  text-decoration: none; transition: all 0.3s ease; box-shadow: 0 10px 25px rgba(0,0,0,0.15);
}
.btn-cta-download:hover { background-color: var(--mint-bg); transform: translateY(-2px) scale(1.02); box-shadow: 0 15px 30px rgba(0,0,0,0.2); }
.footer-container { background-color: #126524; color: var(--light-text); padding: 30px 5% 20px; }
.footer-wrapper { max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 1.5fr 1fr 1fr; gap: 50px; }
.footer-brand { display: flex; flex-direction: column; gap: 20px; }
.footer-logo {
  height: 50px; align-self: flex-start; background: #ffffff;
  padding: 8px 16px; border-radius: 30px; border: 1px solid rgba(255,255,255,0.9);
  box-shadow: 0 5px 15px rgba(0,0,0,0.2); object-fit: contain;
}
.footer-desc { font-size: 15px; line-height: 1.6; opacity: 0.9; }
.footer-title { font-size: 14px; font-weight: 700; letter-spacing: 1px; margin-bottom: 24px; color: #ffffff; }
.footer-links, .footer-contact { display: flex; flex-direction: column; gap: 12px; }
.footer-links a, .footer-contact a { color: rgba(255,255,255,0.9); text-decoration: none; font-size: 15px; transition: color 0.3s ease; }
.footer-links a:hover, .footer-contact a:hover { color: var(--accent-color); }
.footer-contact span { font-size: 15px; opacity: 0.8; }
.footer-bottom { max-width: 1200px; margin: 40px auto 0; }
.footer-divider { width: 100%; height: 1px; background-color: rgba(238,242,204,0.2); margin-bottom: 24px; }
.copyright { text-align: center; font-size: 14px; opacity: 0.7; }
.fade-in { opacity: 0; transform: translateY(30px); transition: opacity 0.8s ease-out, transform 0.8s ease-out; }
.fade-in.visible { opacity: 1; transform: translateY(0); }
.delay-1 { transition-delay: 0.1s; }
.delay-2 { transition-delay: 0.2s; }
.delay-3 { transition-delay: 0.3s; }
.delay-4 { transition-delay: 0.4s; }
@keyframes fadeInUpBounce {
  from { opacity: 0; transform: translateY(60px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes fadeInLeftBounce {
  from { opacity: 0; transform: translateX(100px); }
  to { opacity: 1; transform: translateX(0); }
}
.hero-content > * { opacity: 0; animation: fadeInUpBounce 1s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards; }
.hero-mockup { opacity: 0; animation: fadeInLeftBounce 1.2s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards; animation-delay: 0.4s; }
.hero-content .badge-platform { animation-delay: 0.1s; }
.hero-content .hero-title { animation-delay: 0.3s; }
.hero-content .hero-desc { animation-delay: 0.5s; }
.hero-content .hero-buttons { animation-delay: 0.7s; }
@media (max-width: 1024px) {
  .hero-wrapper { grid-template-columns: 1fr; text-align: center; gap: 40px; }
  .badge-platform { justify-content: center; }
  .hero-buttons { justify-content: center; }
  .hero-desc { margin-left: auto; margin-right: auto; }
  .about-wrapper { grid-template-columns: 1fr; gap: 50px; }
  .features-grid { grid-template-columns: repeat(2, 1fr); }
  .navbar-menu { display: none; }
}
@media (max-width: 768px) {
  section { padding: 80px 5% 60px; }
  .hero-title { font-size: 38px; }
  .section-title { font-size: 32px; }
  .features-grid { grid-template-columns: 1fr; }
  .footer-wrapper { grid-template-columns: 1fr; gap: 40px; }
  .team-row { gap: 30px; }
}
  </style>
</head>
<body>
  <div class="blob blob-1"></div>
  <div class="blob blob-2"></div>
  <div class="blob blob-3"></div>

  <header class="navbar-container">
    <div class="navbar-wrapper">
      <div class="navbar-logo">
        <img src="/images/v20_8.png" alt="AgriConnect Logo">
      </div>
      <nav class="navbar-menu">
        <a href="#hero">Beranda</a>
        <a href="#about">Tentang Kami</a>
        <a href="#features">Fitur</a>
        <a href="#workflow">Cara Kerja</a>
        <a href="#team">Tim Pengembang</a>
        <a href="#faq">FAQ</a>
      </nav>
      <div class="navbar-cta">
        <a href="/download/agriconnect.apk" download class="btn-navbar">Download</a>
      </div>
    </div>
  </header>

  <section id="hero" class="hero-section">
    <div class="hero-wrapper">
      <div class="hero-content">
        <div class="badge-platform">
          <span class="dot-green"></span>
          PLATFORM PERTANIAN DIGITAL
        </div>
        <h1 class="hero-title">
          Kelola Panen,<br>
          Jual Lebih Mudah<br>
          Dengan <span class="highlight">AgriConnect</span>
        </h1>
        <p class="hero-desc">
          AgriConnect adalah solusi digital terbaik untuk komoditas Beras dan Jagung. Kami menghubungkan petani lokal dengan pembeli secara langsung untuk rantai pasok yang lebih transparan dan efisien.
        </p>
        <div class="hero-buttons">
          <a href="/download/agriconnect.apk" download class="btn-primary">Unduh Aplikasi Sekarang</a>
          <a href="#features" class="btn-secondary">Pelajari Fitur</a>
        </div>
      </div>
      <div class="hero-mockup">
        <div class="phone-container phone-left">
          <img src="/images/petani_mockup.jpeg" alt="Beranda Petani">
          <div class="phone-label">Petani</div>
        </div>
        <div class="phone-container phone-center">
          <img src="/images/v98_59.jpeg" alt="Login">
          <div class="phone-label">Login</div>
        </div>
        <div class="phone-container phone-right">
          <img src="/images/pembeli_mockup.jpeg" alt="Beranda Pembeli">
          <div class="phone-label">Pembeli</div>
        </div>
      </div>
    </div>
  </section>

  <section id="about" class="about-section">
    <div class="about-wrapper">
      <div class="about-content fade-in">
        <span class="section-tag">TENTANG KAMI</span>
        <h2 class="section-title">Mendigitalkan Rantai Pasok Pertanian Indonesia</h2>
        <p class="about-desc">
          AgriConnect berkomitmen untuk memotong jalur distribusi komoditas Beras dan Jagung yang panjang dan tidak transparan. Melalui teknologi digital, kami memberdayakan petani agar memiliki kendali penuh atas harga jual mereka sendiri, sambil memudahkan pembeli skala besar maupun retail mendapatkan kualitas terbaik langsung dari sumbernya.
        </p>
        <ul class="about-checklist">
          <li>
            <img src="/images/v98_75.png" alt="Check" class="check-icon">
            <div>
              <strong>Tanpa Perantara Tidak Resmi</strong>
              <p>Interaksi langsung antara produsen utama dengan pembeli tanpa markup harga berlebih.</p>
            </div>
          </li>
          <li>
            <img src="/images/v98_79.png" alt="Check" class="check-icon">
            <div>
              <strong>Pembayaran Instan Terintegrasi</strong>
              <p>Pembayaran aman dengan virtual account, e-wallet, dan QRIS didukung oleh Midtrans.</p>
            </div>
          </li>
        </ul>
      </div>
      <div class="about-commodity fade-in delay-1">
        <div class="commodity-card">
          <div class="commodity-icon">
            <img src="/images/commodity-combined.png" alt="Corn and Grain illustration" class="combined-icon">
          </div>
          <h3 class="commodity-card-title">Informasi Komoditas</h3>
          <p class="commodity-card-desc">
            Aplikasi kami dioptimalkan secara mendalam untuk mendukung komoditas biji-bijian khusus seperti Beras dan Jagung dengan standardisasi harga referensi daerah.
          </p>
          <div class="commodity-table">
            <div class="table-row"><span class="commodity-name">Beras Standar</span><span class="commodity-price">Rp 13.000 - Rp 15.000 /kg</span></div>
            <div class="table-row"><span class="commodity-name">Beras Premium</span><span class="commodity-price">Rp 15.000 - Rp 18.000 /kg</span></div>
            <div class="table-row"><span class="commodity-name">Jagung Standar</span><span class="commodity-price">Rp 9.000 - Rp 13.000 /kg</span></div>
            <div class="table-row"><span class="commodity-name">Jagung Premium</span><span class="commodity-price">Rp 10.000 - Rp 17.000 /kg</span></div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section id="features" class="features-section">
    <div class="features-header fade-in">
      <span class="section-tag centered">FITUR UNGGULAN</span>
      <h2 class="section-title centered">Semua yang Anda Butuhkan dalam Genggaman</h2>
      <p class="section-subtitle centered">Solusi terpadu yang dirancang dari lapangan untuk meningkatkan produktivitas serta kemudahan niaga hasil bumi Anda.</p>
    </div>
    <div class="features-grid">
      <div class="feature-card fade-in">
        <div class="feature-icon-wrapper"><span class="feature-emoji">📋</span></div>
        <h3 class="feature-card-title">Manajemen Stok Hasil Panen</h3>
        <p class="feature-card-desc">Unggah stok beras dan jagung lengkap dengan foto, deskripsi kualitas, dan harga per kilogram dengan sekali ketuk.</p>
      </div>
      <div class="feature-card fade-in">
        <div class="feature-icon-wrapper"><span class="feature-emoji">📅</span></div>
        <h3 class="feature-card-title">Kalender Tanam &amp; Estimasi</h3>
        <p class="feature-card-desc">Sistem penjadwalan aktivitas tanam terintegrasi yang menghitung prediksi tanggal panen dan memberikan pengingat email otomatis.</p>
      </div>
      <div class="feature-card fade-in">
        <div class="feature-icon-wrapper"><span class="feature-emoji">💰</span></div>
        <h3 class="feature-card-title">Manajemen Untung Transparan</h3>
        <p class="feature-card-desc">Mendukung label "Penjualan Kotor" dan "Penjualan Bersih" yang transparan untuk pemantauan profitabilitas nyata Anda.</p>
      </div>
      <div class="feature-card fade-in">
        <div class="feature-icon-wrapper"><span class="feature-emoji">🛒</span></div>
        <h3 class="feature-card-title">Metode Pembayaran Midtrans</h3>
        <p class="feature-card-desc">Pembayaran digital real-time dengan status yang terintegrasi otomatis untuk menghindari bukti transfer palsu.</p>
      </div>
      <div class="feature-card fade-in">
        <div class="feature-icon-wrapper"><span class="feature-emoji">📊</span></div>
        <h3 class="feature-card-title">Ekspor Laporan PDF</h3>
        <p class="feature-card-desc">Unduh salinan laporan keuangan dan ringkasan aktivitas dalam format PDF berkualitas tinggi untuk kebutuhan pembukuan eksternal Anda.</p>
      </div>
      <div class="feature-card">
        <div class="feature-icon-wrapper"><span class="feature-emoji">🤖</span></div>
        <h3 class="feature-card-title">Asisten Edukasi Chatbot AI</h3>
        <p class="feature-card-desc">Konsultasikan hama tanaman, kiat pemupukan beras optimal, dan panduan penggunaan aplikasi melalui chatbot interaktif pintar.</p>
      </div>
    </div>
  </section>

  <section id="workflow" class="workflow-section">
    <div class="workflow-header fade-in">
      <span class="section-tag centered">CARA KERJA</span>
      <h2 class="section-title centered">Alur Kerja Digital yang Sangat Mudah</h2>
    </div>
    <div class="workflow-grid">
      <div class="workflow-card fade-in">
        <div class="workflow-number">01</div>
        <h3 class="workflow-card-title">Unduh Aplikasi</h3>
        <p class="workflow-card-desc">Unduh aplikasi dari tautan web ini dan lakukan pendaftaran akun sebagai Petani atau Pembeli.</p>
      </div>
      <div class="workflow-card fade-in">
        <div class="workflow-number">02</div>
        <h3 class="workflow-card-title">Publikasi / Cari Stok</h3>
        <p class="workflow-card-desc">Petani mengunggah persediaan hasil tanam mereka. Pembeli dapat mencari sesuai kebutuhan komoditas mereka.</p>
      </div>
      <div class="workflow-card fade-in">
        <div class="workflow-number">03</div>
        <h3 class="workflow-card-title">Transaksi &amp; Bayar</h3>
        <p class="workflow-card-desc">Lakukan transaksi pemesanan, lalu bayar secara instan menggunakan QRIS atau transfer antar bank resmi.</p>
      </div>
      <div class="workflow-card fade-in">
        <div class="workflow-number">04</div>
        <h3 class="workflow-card-title">Pengiriman &amp; Laporan</h3>
        <p class="workflow-card-desc">Pesanan dikirimkan, status dilacak secara langsung, dan pendapatan petani langsung tercatat secara rapi.</p>
      </div>
    </div>
  </section>

  <section id="team" class="team-section">
    <div class="team-header fade-in">
      <span class="section-tag centered">TIM PENGEMBANG</span>
      <h2 class="section-title centered">Para Pengembang AgriConnect</h2>
    </div>
    <div class="team-container">
      <div class="team-row row-top">
        <div class="team-member fade-in">
          <div class="avatar-wrapper">
            <div class="avatar-glow"></div>
            <img src="/images/v119_142.png" alt="Jilan Jalillah" class="avatar-img">
            <div class="role-badge">Project Manager</div>
          </div>
          <h3 class="member-name">JILAN JALILLAH</h3>
          <span class="member-npm">NPM 20241320039</span>
        </div>
        <div class="team-member fade-in">
          <div class="avatar-wrapper">
            <div class="avatar-glow"></div>
            <img src="/images/v124_17.png" alt="Keysha Aprilya Salsabila" class="avatar-img">
            <div class="role-badge">System Analyst</div>
          </div>
          <h3 class="member-name">KEYSHA APRILYA SALSABILA</h3>
          <span class="member-npm">NPM 20241320032</span>
        </div>
      </div>
      <div class="team-row row-bottom">
        <div class="team-member fade-in">
          <div class="avatar-wrapper">
            <div class="avatar-glow"></div>
            <img src="/images/v124_12.png" alt="Jopan Maurizt Latue" class="avatar-img">
            <div class="role-badge">FrontEnd Developer</div>
          </div>
          <h3 class="member-name">JOPAN MAURIZT LATUE</h3>
          <span class="member-npm">NPM 20241320040</span>
        </div>
        <div class="team-member fade-in">
          <div class="avatar-wrapper">
            <div class="avatar-glow"></div>
            <img src="/images/v124_19.jpeg" alt="Arya Adi Muhammad Iqbal" class="avatar-img">
            <div class="role-badge">BackEnd Developer</div>
          </div>
          <h3 class="member-name">ARYA ADI MUHAMMAD IQBAL</h3>
          <span class="member-npm">NPM 20241320018</span>
        </div>
        <div class="team-member fade-in">
          <div class="avatar-wrapper">
            <div class="avatar-glow"></div>
            <img src="/images/v124_18.jpeg" alt="Ridho Gustama" class="avatar-img">
            <div class="role-badge">Quality Assurance</div>
          </div>
          <h3 class="member-name">RIDHO GUSTAMA</h3>
          <span class="member-npm">NPM 20241320027</span>
        </div>
      </div>
    </div>
  </section>

  <section id="faq" class="faq-section">
    <div class="faq-header fade-in">
      <span class="section-tag centered">FAQ</span>
      <h2 class="section-title centered">Pertanyaan yang Sering Diajukan</h2>
    </div>
    <div class="faq-list">
      <div class="faq-item fade-in">
        <h3 class="faq-question">Apakah aplikasi AgriConnect gratis?</h3>
        <p class="faq-answer">Ya, aplikasi AgriConnect dapat diunduh dan digunakan tanpa biaya lisensi bulanan oleh seluruh petani lokal dan pembeli hasil tani beras dan jagung.</p>
      </div>
      <div class="faq-item fade-in">
        <h3 class="faq-question">Bagaimana cara memastikan kualitas hasil tani beras/jagung?</h3>
        <p class="faq-answer">Pembeli dapat melihat deskripsi terperinci, sertifikat, serta berdiskusi dengan chatbot untuk memastikan produk apa yang paling banyak dibeli pada fitur AI yang tersedia sebelum melakukan checkout pembayaran.</p>
      </div>
      <div class="faq-item fade-in">
        <h3 class="faq-question">Metode pembayaran apa saja yang didukung?</h3>
        <p class="faq-answer">Kami bekerjasama dengan Midtrans untuk melayani transfer bank otomatis (BCA, Mandiri, BNI, BRI), QRIS, serta e-wallet terpopuler.</p>
      </div>
    </div>
  </section>

  <section id="cta" class="cta-section">
    <div class="cta-background" style="background-image: url('/images/v28_5.png');"></div>
    <div class="cta-overlay"></div>
    <div class="cta-content fade-in">
      <h2 class="cta-title">Siap Memulai Pertanian Digital?</h2>
      <p class="cta-desc">Dapatkan aplikasi AgriConnect sekarang secara gratis. Kelola hasil panen dengan lebih baik dan dapatkan penawaran harga terbaik langsung di tangan Anda.</p>
      <div class="cta-buttons">
        <a href="/download/agriconnect.apk" download class="btn-cta-download">Download APK (Android)</a>
      </div>
    </div>
  </section>

  <footer class="footer-container">
    <div class="footer-wrapper">
      <div class="footer-brand">
        <img src="/images/v30_10.png" alt="AgriConnect Logo" class="footer-logo">
        <p class="footer-desc">Platform digital terbaik untuk komoditas padi dan jagung. Kami menghubungkan petani lokal dengan pembeli secara langsung untuk rantai pasok yang lebih transparan dan efisien.</p>
      </div>
      <div class="footer-links">
        <h4 class="footer-title">HALAMAN RESMI</h4>
        <a href="#hero">Beranda</a>
        <a href="#about">Tentang Kami</a>
        <a href="#features">Fitur</a>
        <a href="#workflow">Cara Kerja</a>
        <a href="#team">Tim Pengembang</a>
        <a href="#faq">FAQ</a>
      </div>
      <div class="footer-contact">
        <h4 class="footer-title">HUBUNGI KAMI</h4>
        <a href="mailto:agriconnect0626@gmail.com">agriconnect0626@gmail.com</a>
        <a href="tel:+6285659202445">+62 856-5920-2445</a>
        <span>Bandung, Indonesia</span>
      </div>
    </div>
    <div class="footer-bottom">
      <div class="footer-divider"></div>
      <p class="copyright">© 2026 AgriConnect. Seluruh hak cipta dilindungi undang-undang.</p>
    </div>
  </footer>

  <script>
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) { target.scrollIntoView({ behavior: 'smooth' }); }
      });
    });
    window.addEventListener('scroll', () => {
      let current = '';
      document.querySelectorAll('section').forEach(section => {
        if (pageYOffset >= (section.offsetTop - 150)) { current = section.getAttribute('id'); }
      });
      document.querySelectorAll('.navbar-menu a').forEach(a => {
        a.classList.remove('active');
        if (a.getAttribute('href').slice(1) === current) { a.classList.add('active'); }
      });
    });
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => { if (entry.isIntersecting) { entry.target.classList.add('visible'); } });
    }, { root: null, rootMargin: '0px', threshold: 0.1 });
    document.querySelectorAll('.fade-in').forEach(el => observer.observe(el));
  </script>
</body>
</html>
