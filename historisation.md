# Historisation — app_mobile_ca

> Suivi de toutes les actions, créations de fichiers et mises à jour du projet.

---

## [2026-03-03] — Initialisation du projet

### Création du dossier
- Création du répertoire `/Applications/XAMPP/claude/app_mobile_ca/`
- Création du fichier `prompt.md` (cahier des charges de l'application)

---

## [2026-03-03] — Génération de l'architecture Flutter complète

### Contexte
Exécution du prompt technique Flutter (Clean Architecture, Riverpod, Dio, Hive, mode offline).
Style : épuré, couleurs primaires **orange** `#FF6B00` et **bleu** `#1565C0`.

---

### Fichiers créés

#### Configuration
| Fichier | Description |
|---------|-------------|
| `pubspec.yaml` | Dépendances : flutter_riverpod, dio, hive_flutter, image_picker, geolocator, flutter_secure_storage, flutter_image_compress, connectivity_plus, intl |

#### Core
| Fichier | Description |
|---------|-------------|
| `lib/core/constants/app_colors.dart` | Palette de couleurs (orange, bleu, statuts, neutres) |
| `lib/core/constants/api_constants.dart` | Base URL et endpoints REST (`/login`, `/collect`, `/my-collects`) |
| `lib/core/theme/app_theme.dart` | Thème Material 3 : AppBar bleue, boutons orange, inputs arrondis |
| `lib/core/errors/exceptions.dart` | Exceptions techniques : `ServerException`, `NetworkException`, `UnauthorizedException`, `ValidationException`, `CacheException` |
| `lib/core/errors/failures.dart` | Failures domaine : `ServerFailure`, `NetworkFailure`, `UnauthorizedFailure`, `ValidationFailure`, `CacheFailure` |
| `lib/core/network/dio_client.dart` | Client Dio avec intercepteur JWT automatique + mapping erreurs |
| `lib/core/network/network_info.dart` | Détection connectivité via `connectivity_plus` |
| `lib/core/storage/secure_storage.dart` | Stockage sécurisé token JWT et user (flutter_secure_storage) |

#### Feature — Auth
| Fichier | Description |
|---------|-------------|
| `lib/features/auth/domain/entities/user.dart` | Entité `User` (id, nom, email, zone) |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Interface `AuthRepository` |
| `lib/features/auth/domain/usecases/login_usecase.dart` | Use case `LoginUsecase` |
| `lib/features/auth/data/models/user_model.dart` | `UserModel` : sérialisation JSON + stockage string |
| `lib/features/auth/data/datasources/auth_remote_datasource.dart` | Appel API POST `/login` |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Implémentation : login + persistance token |
| `lib/features/auth/presentation/providers/auth_provider.dart` | `AuthNotifier` + sealed state (`AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError`) |
| `lib/features/auth/presentation/screens/login_screen.dart` | Écran connexion : header bleu, carte blanche, bouton orange |

#### Feature — Collect
| Fichier | Description |
|---------|-------------|
| `lib/features/collect/domain/entities/collect.dart` | Entités `CollectFormData` (15 champs) + `Collect` + enum `CollectStatus` |
| `lib/features/collect/domain/repositories/collect_repository.dart` | Interface `CollectRepository` |
| `lib/features/collect/domain/usecases/submit_collect_usecase.dart` | Use case soumission formulaire |
| `lib/features/collect/domain/usecases/get_my_collects_usecase.dart` | Use case récupération liste |
| `lib/features/collect/data/models/collect_model.dart` | `CollectModel` : désérialisation API + parsing statut |
| `lib/features/collect/data/datasources/collect_remote_datasource.dart` | POST `/collect` multipart/form-data + compression image + GET `/my-collects` |
| `lib/features/collect/data/datasources/collect_local_datasource.dart` | Sauvegarde offline dans Hive (`pending_collects`) |
| `lib/features/collect/data/repositories/collect_repository_impl.dart` | Logique online/offline + sync automatique des collectes en attente |
| `lib/features/collect/presentation/providers/collect_provider.dart` | `CollectNotifier` + `collectsListProvider` (FutureProvider) |
| `lib/features/collect/presentation/screens/collect_list_screen.dart` | Liste des collectes avec pull-to-refresh, badges statut, état vide |
| `lib/features/collect/presentation/screens/collect_form_screen.dart` | Formulaire complet : 15 champs, 2 dropdowns, géolocalisation, 2 file pickers, date picker |
| `lib/features/collect/presentation/widgets/collect_card.dart` | Carte collecte avec badge statut coloré |
| `lib/features/collect/presentation/widgets/image_picker_field.dart` | Widget réutilisable : caméra / galerie / prévisualisation / suppression |

#### Points d'entrée
| Fichier | Description |
|---------|-------------|
| `lib/di.dart` | Injection de dépendances manuelle + `AppDI.overrides` pour ProviderScope |
| `lib/app.dart` | Root widget : routing auth-aware (LoginScreen ↔ CollectListScreen) |
| `lib/main.dart` | Bootstrap : Hive, orientation portrait, status bar, ProviderScope |

---

### Choix techniques retenus
- **Riverpod** (vs Bloc) : moins de boilerplate, DI via `ProviderScope.overrides`, sealed states natifs Dart 3
- **Mode offline** : sauvegarde Hive si pas de réseau, sync automatique au prochain chargement de la liste
- **Compression image** : `flutter_image_compress` à 70% / 1024px avant upload multipart
- **DI** : injection manuelle dans `di.dart` (pas de `get_it`), overrides Riverpod

---

---

## [2026-03-03] — Remplacement email → identifiant + Mock data

### Contexte
Le modèle backend n'utilise pas d'email mais un identifiant texte.
Ajout de datasources mockées pour les tests sans API.

### Fichiers modifiés
| Fichier | Type | Description |
|---------|------|-------------|
| `lib/features/auth/domain/entities/user.dart` | Modification | `email` → `identifiant` |
| `lib/features/auth/data/models/user_model.dart` | Modification | `email` → `identifiant` + mapping JSON `identifiant` |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Modification | Signature `login` : `email` → `identifiant` |
| `lib/features/auth/domain/usecases/login_usecase.dart` | Modification | Signature `call` : `email` → `identifiant` |
| `lib/features/auth/data/datasources/auth_remote_datasource.dart` | Modification | Payload API : `email` → `identifiant` |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Modification | Propagation du paramètre `identifiant` |
| `lib/features/auth/presentation/providers/auth_provider.dart` | Modification | Signature `login` : `email` → `identifiant` |
| `lib/features/auth/presentation/screens/login_screen.dart` | Modification | Champ email → champ identifiant (`badge_outlined`, clavier text) |
| `lib/di.dart` | Modification | Flag `kMockMode` + switch mock/prod + import mocks |

### Fichiers créés
| Fichier | Description |
|---------|-------------|
| `lib/features/auth/data/datasources/auth_mock_datasource.dart` | Mock auth : 3 comptes (agent01, agent02, superviseur) avec délai simulé |
| `lib/features/collect/data/datasources/collect_mock_datasource.dart` | Mock collect : 5 collectes pré-chargées (statuts variés) + soumission en mémoire |

### Comptes de test (kMockMode = true)
| Identifiant | Mot de passe | Zone |
|-------------|-------------|------|
| agent01 | password | Abidjan Nord |
| agent02 | password | Abidjan Sud |
| superviseur | admin123 | Toutes zones |

### Pour passer en production
Dans `lib/di.dart`, changer :
```dart
const bool kMockMode = true; // → false
```

---

## Template pour les prochaines entrées

```
## [YYYY-MM-DD] — Titre de la mise à jour

### Fichiers modifiés
| Fichier | Type | Description |
|---------|------|-------------|
| `chemin/fichier.dart` | Création / Modification / Suppression | Détail |

### Changements
- ...
```
