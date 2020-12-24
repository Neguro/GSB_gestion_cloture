﻿using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GSB_gestion_cloture
{
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

        public void Find(string colonnes, string table, string condition)
        {
            string sql = $@"Select {colonnes} from {table} where {condition}";
            MySqlCommand command = new MySqlCommand(sql, getInstance().connexion);
            try
            {
                command.ExecuteScalar();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public void Find(string colonnes, string table)
        {
            string sql = $@"Select {colonnes} from {table}";
            MySqlCommand command = new MySqlCommand(sql, getInstance().connexion);
            try
            {      
                command.ExecuteScalar();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public void FindAll(string table)
        {
            string sql = $@"Select * from {table}";
            MySqlCommand command = new MySqlCommand(sql, getInstance().connexion);
            try
            {            
                command.ExecuteScalar();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public void FindAll(string table, string conditions)
        {
            string sql = $@"Select * from {table} where {conditions}";
            MySqlCommand command = new MySqlCommand(sql, getInstance().connexion);
            try
            {
                command.ExecuteScalar();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public void Delete(string table, string condition)
        {
            string sql = $@"Delete from {table} where {condition}";
            MySqlCommand command = new MySqlCommand(sql, getInstance().connexion);
            try
            {
                command.ExecuteNonQuery();
            }
            catch (MySqlException ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public void Update(string table, string colonne, string valeur, string condition)
        {
            string sql = $@"Update {table} set {colonne} = {valeur} where {condition}"; 
            MySqlCommand command = new MySqlCommand(sql, getInstance().connexion);
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
