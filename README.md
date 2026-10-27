# NIAM-NIAM 🍽️

Application mobile de découverte culinaire, de commande et de livraison, développée dans le cadre du module **Développement d'Applications Mobiles** (L3 Informatique, UFR SAT — Université Gaston Berger de Saint-Louis).

## 📌 Présentation

NIAM-NIAM met en relation les clients avec les restaurants, fast-foods et maïgas de Saint-Louis et du Sénégal. Chaque établissement présente son profil et ses plats. Les clients peuvent les découvrir (liste, carte, recherche, favoris), commander avec une position de livraison précise, puis suivre leur commande jusqu'à la livraison.

## 🎯 Problématique

Au Sénégal, trouver un bon endroit où manger repose encore largement sur le bouche-à-oreille : peu d'outils permettent de comparer restaurants, fast-foods et maïgas, de consulter leurs plats et les avis d'autres clients. À l'inverse, les petites structures ont peu de visibilité en ligne. NIAM-NIAM répond à ce double besoin en combinant découverte d'établissements et commande avec livraison.

## 👥 Équipe

| Nom | Rôle |
|---|---|
| Maoudo DIAW | Développeur |
| Moussa CISSÉ | Développeur |

Encadrant : Pr. Maïssa MBAYE

## 🧩 Rôles dans l'application

- **Client** : découvre les établissements, commande, suit sa livraison, laisse un avis
- **Gérant** : crée et gère son établissement et ses plats, reçoit et prépare les commandes, consulte ses statistiques
- **Livreur** : consulte les missions disponibles, accepte une mission, suit son parcours sur une carte et livre

## ✅ Fonctionnalités

- [x] Inscription, connexion et choix du rôle (Firebase Authentication)
- [x] Création et modification d'un établissement, gestion des plats (gérant)
- [x] Écran d'accueil, liste des établissements, recherche, favoris
- [x] Carte des établissements (OpenStreetMap) avec icônes par type d'établissement
- [x] Panier multi-plats et passage de commande
- [x] Position de livraison (GPS, pointage sur la carte, repère)
- [x] Cycle de vie de la commande : confirmée → en préparation → prête → livreur assigné → récupérée → en route → livrée
- [x] Missions de livraison avec carte du livreur (restaurant, puis client)
- [x] Notifications dans l'application
- [x] Avis et notation après livraison
- [x] Page Aide et assistance (À propos + contact WhatsApp)
- [ ] Paiement Mobile Money à la commande (prévu avant le déploiement)
- [ ] Suivi du livreur en temps réel sur la carte du client (perspective)

Le détail complet est dans le rapport du projet.

## 🛠️ Stack technique

- **Application mobile** : Flutter (Dart)
- **Backend** : Firebase — Authentication et Cloud Firestore (données en temps réel)
- **Cartographie** : `flutter_map` avec OpenStreetMap, `latlong2`
- **Localisation** : `geolocator`
- **Liens externes** : `url_launcher` (appel, WhatsApp)

## 📁 Structure du projet

```
niam-niam/
└── lib/
    ├── main.dart, theme.dart, firebase_options.dart
    ├── models/      # Utilisateur, Client, Livreur, Etablissement, Produit, Commande, Avis, notifications
    ├── screens/
    │   ├── client/  # accueil, fiche établissement, commande, suivi, favoris, profil
    │   ├── gerant/  # établissement, plats, commandes reçues, statistiques
    │   └── livreur/ # missions, carte, historique, profil
    ├── services/    # accès Firebase (auth, commandes, établissements, favoris, avis, notifications…)
    └── widgets/     # composants réutilisables
```

## 🚀 Démarrage

Prérequis : [Flutter](https://docs.flutter.dev/get-started/install) installé, un émulateur Android ou un téléphone, et la configuration Firebase du projet (`firebase_options.dart` et, sur Android, `android/app/google-services.json`).

```bash
git clone https://github.com/Maoudo-4/niam-niam.git
cd niam-niam
flutter pub get
flutter run
```

## 🎬 Livrables

- Rapport du projet : à compléter (lien ou fichier)
- Vidéo de démonstration : à compléter (lien)

## 🌿 Workflow de collaboration (binôme)

- `main` : branche stable
- `dev` : branche d'intégration
- Une branche par fonctionnalité (ex. `feature/esthetique`), fusionnée dans `dev` par **Pull Request**

## 👤 Répartition du travail

| Partie | Responsable(s) |
|---|---|
| Authentification et profils | Moussa |
| Établissements, écran d'accueil, recherche | Moussa et Maoudo |
| Commande | Maoudo |
| Système de livraison (statuts, missions, GPS) | Maoudo et Moussa |

Le détail est dans la partie 6 du rapport.
| Auth + profils (client/gérant/livreur) | Moussa |
| Établissements + fil d'actualité + recherche | Moussa + Maoudo |
| Commande + paiement | Maoudo |
| Système de livraison (statuts, pool, GPS) | Maoudo + Moussa |

## @all right reserved | @Droit d'auteur

Projet académique — UFR SAT, Université Gaston Berger de Saint-Louis.