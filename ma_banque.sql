-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 13 mars 2025 à 15:53
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `ma_banque`
--

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

CREATE TABLE `client` (
  `UID` int(10) NOT NULL,
  `Nom` varchar(255) DEFAULT NULL,
  `Prénom` varchar(255) DEFAULT NULL,
  `Numéro_de_compte` int(20) DEFAULT NULL,
  `Sociétaire` enum('Oui','Non') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `client`
--

INSERT INTO `client` (`UID`, `Nom`, `Prénom`, `Numéro_de_compte`, `Sociétaire`) VALUES
(1, 'Dupont', 'Jean', 123456789, 'Oui'),
(2, 'Martin', 'Marie', 987654321, 'Non'),
(3, 'Durand', 'Paul', 456789123, 'Oui'),
(4, 'Lefevre', 'Sophie', 789123456, 'Non'),
(5, 'Moreau', 'Luc', 321654987, 'Oui'),
(6, 'Garnier', 'Claire', 654987321, 'Non'),
(7, 'Chevalier', 'Marc', 987321654, 'Oui'),
(8, 'Bernard', 'Julie', 321987654, 'Non'),
(9, 'Rousseau', 'Antoine', 654321987, 'Oui'),
(10, 'Muller', 'Hélène', 987654321, 'Non');

-- --------------------------------------------------------

--
-- Structure de la table `cotisation`
--

CREATE TABLE `cotisation` (
  `ID` int(10) NOT NULL,
  `ID_trans` int(10) DEFAULT NULL,
  `Cotisation` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `cotisation`
--

INSERT INTO `cotisation` (`ID`, `ID_trans`, `Cotisation`) VALUES
(60, 14, 0.02),
(61, 18, 0.02),
(62, 22, 0.02),
(63, 24, 0.02),
(64, 34, 0.02),
(65, 36, 0.02),
(66, 38, 0.02),
(67, 42, 0.02);

-- --------------------------------------------------------

--
-- Structure de la table `transaction`
--

CREATE TABLE `transaction` (
  `ID_trans` int(10) NOT NULL,
  `UID` int(10) DEFAULT NULL,
  `TYPE` enum('CB','Chèque','Retrait','Virement') DEFAULT NULL,
  `Prix` int(255) DEFAULT NULL,
  `Date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `transaction`
--

INSERT INTO `transaction` (`ID_trans`, `UID`, `TYPE`, `Prix`, `Date`) VALUES
(14, 1, 'CB', 150, '2025-03-03'),
(15, 2, 'Chèque', 200, '2025-01-14'),
(16, 3, 'Retrait', 50, '2025-01-22'),
(17, 4, 'Virement', 300, '2025-03-08'),
(18, 5, 'CB', 100, '2025-02-28'),
(19, 6, 'Chèque', 250, '2025-01-24'),
(20, 7, 'Retrait', 75, '2025-01-10'),
(21, 8, 'Virement', 400, '2025-02-19'),
(22, 9, 'CB', 120, '2025-01-09'),
(23, 10, 'Chèque', 180, '2025-02-04'),
(24, 1, 'CB', 120, '2025-01-15'),
(25, 2, 'Virement', 300, '2025-02-10'),
(26, 3, 'Chèque', 180, '2025-01-20'),
(27, 4, 'CB', 50, '2025-02-18'),
(28, 5, 'Retrait', 200, '2025-03-05'),
(29, 6, 'CB', 75, '2025-01-22'),
(30, 7, 'Virement', 500, '2025-03-10'),
(31, 8, 'CB', 60, '2025-02-15'),
(32, 9, 'Retrait', 150, '2025-01-30'),
(33, 10, 'Chèque', 220, '2025-03-12'),
(34, 1, 'CB', 100, '2025-02-05'),
(35, 2, 'CB', 300, '2025-01-25'),
(36, 3, 'CB', 90, '2025-03-01'),
(37, 4, 'Virement', 200, '2025-02-28'),
(38, 5, 'CB', 130, '2025-01-18'),
(39, 6, 'Retrait', 80, '2025-03-08'),
(40, 7, 'Chèque', 250, '2025-02-27'),
(41, 8, 'CB', 110, '2025-03-11'),
(42, 9, 'CB', 140, '2025-01-12'),
(43, 10, 'Virement', 400, '2025-02-20');

--
-- Déclencheurs `transaction`
--
DELIMITER $$
CREATE TRIGGER `maj_cotisation_apres_transaction` AFTER INSERT ON `transaction` FOR EACH ROW BEGIN
    DECLARE est_sociétaire ENUM('Oui', 'Non');

    -- Vérifier si le client est sociétaire
    SELECT Sociétaire INTO est_sociétaire 
    FROM Client 
    WHERE UID = NEW.UID;

    -- Insérer la cotisation uniquement si le client est sociétaire et si la transaction est de type 'CB'
    IF est_sociétaire = 'Oui' AND NEW.TYPE = 'CB' THEN
        INSERT INTO Cotisation (ID_trans, Cotisation) 
        VALUES (NEW.ID_trans, 0.02); -- Cotisation fixe de 0,02€
    END IF;
END
$$
DELIMITER ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `client`
--
ALTER TABLE `client`
  ADD PRIMARY KEY (`UID`);

--
-- Index pour la table `cotisation`
--
ALTER TABLE `cotisation`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_trans` (`ID_trans`);

--
-- Index pour la table `transaction`
--
ALTER TABLE `transaction`
  ADD PRIMARY KEY (`ID_trans`),
  ADD KEY `UID` (`UID`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `client`
--
ALTER TABLE `client`
  MODIFY `UID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `cotisation`
--
ALTER TABLE `cotisation`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT pour la table `transaction`
--
ALTER TABLE `transaction`
  MODIFY `ID_trans` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `cotisation`
--
ALTER TABLE `cotisation`
  ADD CONSTRAINT `cotisation_ibfk_1` FOREIGN KEY (`ID_trans`) REFERENCES `transaction` (`ID_trans`);

--
-- Contraintes pour la table `transaction`
--
ALTER TABLE `transaction`
  ADD CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`UID`) REFERENCES `client` (`UID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
