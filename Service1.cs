using System;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using MySql.Data;

namespace GSB_gestion_cloture
{
    public partial class Service1 : ServiceBase
    {
        // pour gerer le déclanchement de notre tache avec un thread plutôt qu'un timer. 
        private ThreadStart tsTask;
        private Thread myTask;
        private Bdd bdd = Bdd.getInstance();
        public Service1()
        {
            InitializeComponent();
        }
        /// <summary>
        /// Gestion des évenements lors de l'execution du service.
        /// </summary>
        /// <param name="args"></param>
        protected override void OnStart(string[] args)
        {
            bdd.Ouvrir();
            tsTask = new ThreadStart(TaskLoop);
            myTask = new Thread(tsTask);
            myTask.Start();
        }
        /// <summary>
        /// Gestion des evenement lors de la fermeture du service
        /// </summary>
        protected override void OnStop()
        {
            bdd.Fermer();
            myTask.Abort();
        }

        public void TaskLoop()
        {
            while(true)
            {
                Tasks();
                Thread.Sleep(TimeSpan.FromHours(1)); // Relance le thread toutes les heures.
            }
        }

        /// <summary>
        /// Fonction qui gére les tâches demandées 
        /// </summary>
        public void Tasks()
        {       
            try
            {
                string moisPrecedent = DateTime.Now.Year + GestionDate.getMoisPrecedent();
                // Si nous sommes entre le 1er et le 10 du mois nous démmarons la campagne de validation.
                if(GestionDate.entre(1,10))
                {
                    bdd.Update("fichefrais", "idetat", "CL", $@"mois like '{moisPrecedent}'");
                }
                // Si nous somme le 20ieme ou au dela nous validons toutes les fiches du mois précèdent.
                if(DateTime.Now.Day >= 20)
                {
                    bdd.Update("fichefrais","idetat","RB",$@"idetat = 'VA' and mois like '{moisPrecedent}'");
                }
  
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

    }
}
