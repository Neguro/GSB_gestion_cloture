using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GSB_gestion_cloture
{
    /// <summary>
    /// Classe qui gére la connexion a la base de données.
    /// </summary>
    class Bdd
    {
        private MySqlConnection connexion; // l'objet connexion de votre base de données
        private static Bdd instance; // l'instance de sa propre classe
        /// <summary>
        /// Constructeur
        /// </summary>
        private Bdd()
        {
            ConnectionStringSettings cnMysql = ConfigurationManager.ConnectionStrings["ConnectionString"];
            string cs = string.Format(cnMysql.ConnectionString,
                                                ConfigurationManager.AppSettings["SERVER"],
                                                ConfigurationManager.AppSettings["PORT"],
                                                ConfigurationManager.AppSettings["DATABASE"],
                                                ConfigurationManager.AppSettings["UID"],
                                                ConfigurationManager.AppSettings["PASSWORD"]);
            this.connexion = new MySqlConnection(cs);
        }

        /// <summary>
        /// Accesseur à la propre instance de la classe
        /// En mode static pour ne pas avoir à instancier la classe .....
        /// Du coup l'attribut instance sera en static
        /// </summary>
        /// <returns></returns>
        public static Bdd getInstance()
        {
            if (Bdd.instance == null)
            {
                Bdd.instance = new Bdd();
            }
            return Bdd.instance;
        }

        /// <summary>
        /// Methode qui sert a ouvrir la connexion à la base de données
        /// </summary>
        public void Ouvrir()
        {
            try
            {
                if (this.connexion != null && this.connexion.State == System.Data.ConnectionState.Closed)
                {
                    this.connexion.Open();
                }
            }
            catch (MySqlException ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        /// <summary>
        /// Méthode qui sert a fermer la connexion à la base de données
        /// </summary>
        public void Fermer()
        {
            try
            {
                this.connexion.Close();
                Bdd.instance = null;
            }
            catch (MySqlException ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        /// <summary>
        /// Méthode qui sert a récuperer des informations précise d'une table dans la base de données.
        /// </summary>
        /// <param name="colonne">Les ou la colonne dont on veux recupéré les données.</param>
        /// <param name="table">Table sur laquelle la requête est utilisé.</param>
        public void Find(string colonne, string table)
        {
            string sql = $@"Select {colonne} from {table}";
            MySqlCommand command = new MySqlCommand(sql, Bdd.getInstance().connexion);
            try
            {      
                command.ExecuteScalar();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message);
            }
        }

        /// <summary>
        /// Surcharge de Find(): Méthode qui sert a récuperer des informations précise d'une table dans la base de données (avec une condition).
        /// </summary>
        /// <param name="colonne">Les ou la colonne dont on veux recupéré les données.</param>
        /// <param name="table">Table sur laquelle la requête est utilisé.</param>
        /// <param name="condition">Les ou la condition liée a la requête.</param>
        public void Find(string colonne, string table, string condition)
        {
            string sql = $@"Select {colonne} from {table} where {condition}";
            MySqlCommand command = new MySqlCommand(sql, Bdd.getInstance().connexion);
            try
            {
                command.ExecuteScalar();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message);
            }
        }

        /// <summary>
        /// Méthode qui sert a récuperer toutes les informations d'une table dans la base de données.
        /// </summary>
        /// <param name="table">Table sur laquelle la requête est utilisé.</param>
        public void FindAll(string table)
        {
            string sql = $@"Select * from {table}";
            MySqlCommand command = new MySqlCommand(sql, Bdd.getInstance().connexion);
            try
            {            
                command.ExecuteScalar();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message);
            }
        }

        /// <summary>
        /// Surcharge de FindAll(): Méthode qui sert a récuperer toutes les informations d'une table dans la base de données.
        /// </summary>
        /// <param name="table">Table sur laquelle la requête est utilisé.</param>
        /// <param name="condition">Les ou la condition liée a la requête.</param>
        public void FindAll(string table, string condition)
        {
            string sql = $@"Select * from {table} where {condition}";
            MySqlCommand command = new MySqlCommand(sql, Bdd.getInstance().connexion);
            try
            {
                command.ExecuteScalar();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message);
            }
        }

        /// <summary>
        /// Méthode qui sert a supprimer les lignes d'une table de la base de données.
        /// </summary>
        /// <param name="table">Table sur laquelle la requête est utilisé.</param>
        /// <param name="condition">Les ou la condition liée a la requête.</param>
        public void Delete(string table, string condition)
        {
            string sql = $@"Delete from {table} where {condition}";
            MySqlCommand command = new MySqlCommand(sql, Bdd.getInstance().connexion);
            try
            {
                command.ExecuteNonQuery();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message);
            }
        }

        /// <summary>
        /// Méthode qui sert a mettre à jour une table dans la base de données.
        /// </summary>
        /// <param name="table">Table sur laquelle la requête est utilisé.</param>
        /// <param name="colonne">La colonne dont on veux modifier les données.</param>
        /// <param name="valeur">La valeur qui va remplacer l'ancienne.</param>
        /// <param name="condition">Les ou la condition liée a la requête.</param>
        public void Update(string table, string colonne, string valeur, string condition)
        {
            string sql = $@"Update {table} set {colonne} = {valeur} where {condition}"; 
            MySqlCommand command = new MySqlCommand(sql, Bdd.getInstance().connexion);
            try
            {
                command.ExecuteNonQuery();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message); 
            }
        }

    }
}
