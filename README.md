# NIAM-NIAM 🍽️

Application mobile de découverte culinaire et de mise en relation avec suivi de livraison, développée dans le cadre du module **Développement d'Applications Mobile** (L3 Informatique, UFR SAT — Université Gaston Berger de Saint-Louis).

## 📌 Présentation

NIAM-NIAM connecte les clients aux restaurants, fast-foods et maïga (stands de rue) du Sénégal. Chaque établissement anime une page vivante (menus, plats, événements, annonces) consultable par les clients à proximité, qui peuvent commander, réserver et se faire livrer, avec un **suivi de livraison en temps réel** — la fonctionnalité phare du projet.

## 🎯 Problématique

Au Sénégal, trouver un bon endroit où manger repose encore largement sur le bouche-à-oreille : aucun outil dédié ne permet de comparer facilement restaurants, fast-foods et maïga selon un budget précis, de consulter leurs menus à jour et les avis d'autres clients. À l'inverse, les petites structures ont peu de visibilité en ligne. NIAM-NIAM répond à ce double problème via une application mobile combinant réseau social culinaire et marketplace de commande/livraison.

## 👥 Équipe

| Nom | Rôle |
|---|---|
| Maoudo DIAW | Développeur |
| Moussa CISSE | Développeur |

Encadrant : Pr. Maïssa MBAYE

## 🧩 Acteurs de l'application

- **Client** — recherche un établissement, commande, suit sa livraison
- **Gérant d'établissement** — anime son profil, reçoit les commandes
- **Livreur interne** — rattaché à un établissement
- **Livreur indépendant** — inscrit au pool de livraison partagé

## ✅ Fonctionnalités principales (V1)

- [ ] Créer un profil établissement
- [ ] Publier sur le fil d'actualité
- [ ] Rechercher par localisation et budget
- [ ] Consulter une fiche établissement
- [ ] Commander ou réserver (paiement Mobile Money)
- [ ] Suivre la livraison en temps réel (statuts + position GPS)

Détail complet des fonctionnalités, règles de gestion et modèle de données : voir `docs/Cahier_des_Charges_NIAM-NIAM.docx`.

## 🛠️ Stack technique

- **Frontend mobile** : Flutter (Dart)
- **Backend** : Firebase (Auth, Firestore, Cloud Messaging)
- **Cartographie** : flutter_map / Google Maps API
- **Paiement** : API Mobile Money (Wave, Orange Money) — simulé en environnement académique

## 📁 Structure du projet

```
niam-niam/
├── lib/
│   ├── models/          # Modèles de données (Utilisateur, Etablissement, Commande...)
│   ├── screens/          # Écrans par profil (client/, gerant/, livreur/)
│   ├── services/         # Auth, Firestore, géolocalisation, paiement
│   ├── widgets/           # Composants réutilisables
│   └── main.dart
├── docs/                  # Cahier des charges, maquettes
└── test/
```

## 🚀 Démarrage

```bash
git clone https://github.com/<ton-user>/niam-niam.git
cd niam-niam
flutter pub get
flutter run
```

## 🌿 Workflow de collaboration (binôme)

- `main` : branche stable, protégée — jamais de push direct
- `dev` : branche d'intégration
- Une branche par fonctionnalité : `feature/nom-de-la-fonctionnalite`
  - ex. `feature/auth`, `feature/profil-etablissement`, `feature/suivi-livraison`
- Chaque fonctionnalité est développée sur sa branche, puis fusionnée dans `dev` via **Pull Request** (revue croisée avant merge)
- `dev` est fusionnée dans `main` une fois stable et testée

### Répartition suggérée

| Partie | Responsable |
|---|---|
| Auth + profils (client/gérant/livreur) | À définir |
| Établissements + fil d'actualité + recherche | À définir |
| Commande + paiement | À définir |
| Système de livraison (statuts, pool, GPS) | À définir |

## 📄 Licence

Projet académique — UFR SAT, Université Gaston Berger de Saint-Louis.
