# 📦 Versions Archivées - BTCUSD SmartBot Pro

Ce dossier contient les versions archivées du bot pour référence et rollback si nécessaire.

## 📋 Versions Disponibles

| Version | Fichier | Date | Description |
|---------|---------|------|-------------|
| 1.04 | BTCUSD_SmartBot_Pro_v1.04.mq5 | 2025-11-09 | Grid Orders pending (BuyLimit/SellLimit) |
| 1.05 | BTCUSD_SmartBot_Pro_v1.05.mq5 | 2025-11-09 | Grid Lot Multiplier Fix |

## 🔄 Utilisation

### Pour revenir à une version précédente :

1. **Identifier la version souhaitée** dans le tableau ci-dessus
2. **Copier le fichier** vers le dossier principal :
   ```bash
   cp versions/BTCUSD_SmartBot_Pro_v1.04.mq5 BTCUSD_SmartBot_Pro.mq5
   ```
3. **Compiler** dans MetaEditor
4. **Redémarrer** MT5

### Comparaison entre versions :

Pour voir les différences entre deux versions, utilisez un outil de diff comme `diff` ou MetaEditor Compare :

```bash
diff versions/BTCUSD_SmartBot_Pro_v1.04.mq5 versions/BTCUSD_SmartBot_Pro_v1.05.mq5
```

## ⚠️ Notes Importantes

- **Ne jamais modifier** les fichiers dans ce dossier
- **Toujours tester en DEMO** après un rollback
- **Vérifier le CHANGELOG** pour comprendre les différences entre versions
- Les fichiers archivés sont des **copies de sécurité** uniquement

## 📝 Politique de Versionnage

- Chaque nouvelle version du bot principal est automatiquement archivée ici
- Le nom de fichier inclut le numéro de version : `BTCUSD_SmartBot_Pro_vX.YY.mq5`
- Les versions sont conservées indéfiniment pour traçabilité

## 🔗 Référence

Consultez `CHANGELOG_MT5.md` dans le dossier principal pour les détails complets de chaque version.
