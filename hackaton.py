import mysql.connector
import matplotlib.pyplot as plt


# Fonction pour créer le graphe total des cotisations
def diagramme_cotisations_totales():
    # Connexion à la BSDD
    conn = mysql.connector.connect(
        host="localhost",
        user="root",  
        password="",  
        database="ma_banque"
    )
    cursor = conn.cursor()

    # Requête SQL pour récupérer les cotisations mensuelles
    query = """
    SELECT 
        MONTH(t.Date) AS Mois, 
        SUM(c.Cotisation) AS Total_Cotisation
    FROM 
        cotisation c
    JOIN 
        `transaction` t ON c.ID_trans = t.ID_trans
    WHERE 
        YEAR(t.Date) = 2025
    GROUP BY 
        MONTH(t.Date)
    ORDER BY 
        Mois;
    """
    cursor.execute(query)
    results = cursor.fetchall()

    #données graphique
    mois = []
    cotisations = []
    for row in results:
        mois.append(row[0])  # mois
        cotisations.append(row[1])  # cotisations

    # Fermer la connexion
    cursor.close()
    conn.close()

    # Créer le diagramme
    plt.figure(figsize=(10, 6))
    plt.bar(mois, cotisations, color="skyblue")
    plt.title("Cotisations mensuelles totales en 2025", fontsize=16)
    plt.xlabel("Mois", fontsize=12)
    plt.ylabel("Total des cotisations (€)", fontsize=12)
    plt.xticks(range(1, 13), ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Août", "Sept", "Oct", "Nov", "Déc"])
    plt.grid(axis="y", linestyle="--", alpha=0.7)
    plt.tight_layout()
    plt.show()


# Fonction pour créer le graphe des cotisations des sociétaires (paiements par CB) pour une seule personne
def diagramme_cotisations_mensuelles_societaire_par_client(numero_compte):
    # Connexion à la Bdd
    conn = mysql.connector.connect(
        host="localhost",
        user="root",  
        password="",  
        database="ma_banque"
    )
    cursor = conn.cursor()

    # Récupérer les informations du client (Nom / Prenom)
    client_query = """
    SELECT Nom, Prénom
    FROM client
    WHERE Numéro_de_compte = %s;
    """
    cursor.execute(client_query, (numero_compte,))
    client = cursor.fetchone()
    cursor.fetchall()  

    if not client:
        print(f"Aucun client trouvé avec le numéro de compte : {numero_compte}")
        cursor.close()
        conn.close()
        return

    nom, prenom = client

    # Vérifier si le client est sociétaire ou non
    societaire_query = """
    SELECT Sociétaire
    FROM client
    WHERE Numéro_de_compte = %s;
    """
    cursor.execute(societaire_query, (numero_compte,))
    societaire = cursor.fetchone()
    cursor.fetchall()

    if not societaire or societaire[0] == 'Non':  
        print(f"Le client {prenom} {nom} avec le numéro de compte {numero_compte} n'est pas sociétaire ou n'existe pas.")
        cursor.close()
        conn.close() #kick si c'est pas un sociétaire
        return

    # Requête SQL
    query = """
    SELECT 
        MONTH(t.Date) AS Mois, 
        SUM(c.Cotisation) AS Total_Cotisation
    FROM 
        cotisation c
    JOIN 
        `transaction` t ON c.ID_trans = t.ID_trans
    JOIN 
        client cl ON t.UID = cl.UID
    WHERE 
        cl.Numéro_de_compte = %s AND t.TYPE = 'CB' AND YEAR(t.Date) = 2025
    GROUP BY 
        MONTH(t.Date)
    ORDER BY 
        Mois;
    """
    cursor.execute(query, (numero_compte,))
    results = cursor.fetchall()

    # Fermer la connexion
    cursor.close()
    conn.close()

    # Créer le diagramme
    mois = []
    cotisations = []
    for row in results:
        mois.append(row[0])  
        cotisations.append(row[1])  

    plt.figure(figsize=(10, 6))
    plt.bar(mois, cotisations, color="royalblue")
    plt.title(f"Cotisations mensuelles pour {prenom} {nom} en 2025 (paiements par CB)", fontsize=16)
    plt.xlabel("Mois", fontsize=12)
    plt.ylabel("Total des cotisations (€)", fontsize=12)
    plt.xticks(range(1, 13), ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Août", "Sept", "Oct", "Nov", "Déc"])
    plt.grid(axis="y", linestyle="--", alpha=0.7)
    plt.tight_layout()
    plt.show()

# Fonction pour créer le graphe de l'épargne verte potentielle pour un compte non sociétaire
def diagramme_epargne_verte_potentielle_par_client(numero_compte):
    # Connexion à la base de données
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="ma_banque"
    )
    cursor = conn.cursor()

    
    client_query = """
    SELECT Nom, Prénom
    FROM client
    WHERE Numéro_de_compte = %s;
    """
    cursor.execute(client_query, (numero_compte,))
    client = cursor.fetchone()
    cursor.fetchall()  

    if not client:
        print(f"Aucun client trouvé avec le numéro de compte : {numero_compte}")
        cursor.close()
        conn.close()
        return

    nom, prenom = client

    # Vérifier si le client est non sociétaire
    societaire_query = """
    SELECT Sociétaire
    FROM client
    WHERE Numéro_de_compte = %s;
    """
    cursor.execute(societaire_query, (numero_compte,))
    societaire = cursor.fetchone()
    cursor.fetchall()

    if not societaire or societaire[0] == 'Oui':  
        print(f"Le client {prenom} {nom} avec le numéro de compte {numero_compte} est sociétaire ou n'existe pas.")
        cursor.close()
        conn.close() # le kick s'il est sociétaire
        return

    # Requête SQL pour récupérer les transactions CB des non sociétaires et calculer l'épargne verte potentielle
    query = """
    SELECT 
        MONTH(t.Date) AS Mois, 
        COUNT(t.ID_trans) * 0.02 AS Epargne_Verte
    FROM 
        `transaction` t
    JOIN 
        client c ON t.UID = c.UID
    WHERE 
        c.Numéro_de_compte = %s AND t.TYPE = 'CB' AND YEAR(t.Date) = 2025
    GROUP BY 
        MONTH(t.Date)
    ORDER BY 
        Mois;
    """
    cursor.execute(query, (numero_compte,))
    results = cursor.fetchall()

    #Fermer la connexion
    cursor.close()
    conn.close()

    #Créer le diagramme
    mois = []
    epargne_verte = []
    for row in results:
        mois.append(row[0])  
        epargne_verte.append(row[1])  

    plt.figure(figsize=(10, 6))
    plt.bar(mois, epargne_verte, color="forestgreen")
    plt.title(f"Epargne Verte Potentielle en 2025 pour {prenom} {nom}", fontsize=16)
    plt.xlabel("Mois", fontsize=12)
    plt.ylabel("Total de l'épargne verte (€)", fontsize=12)
    plt.xticks(range(1, 13), ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Août", "Sept", "Oct", "Nov", "Déc"])
    plt.grid(axis="y", linestyle="--", alpha=0.7)
    plt.tight_layout()
    plt.show()

#Exemple d'utilisation de la commande
diagramme_cotisations_totales()
diagramme_cotisations_mensuelles_societaire_par_client('123456789')  
diagramme_epargne_verte_potentielle_par_client('987654321')
