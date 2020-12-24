using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Timers;

namespace GSB_gestion_cloture
{
    public partial class Service1 : ServiceBase
    {
        private Timer timer = new Timer(); // creation du timer pour le service
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
            Bdd.getInstance().Ouvrir();
            this.timer.Elapsed += new ElapsedEventHandler(Tasks);
            this.timer.Interval = 5000;
            this.timer.Start();
        }
        /// <summary>
        /// Gestion des evenement lors de la fermeture du service
        /// </summary>
        protected override void OnStop()
        {
            Bdd.getInstance().Fermer();
            this.timer.Stop();
        }
        /// <summary>
        /// Fonction qui gére les tâches demandées 
        /// </summary>
        private void Tasks(object source, ElapsedEventArgs e)
        {
            
            try
            {
                string moisPrecedent = DateTime.Now.Year + GestionDate.getMoisPrecedent();
                
                if(GestionDate.entre(1,10))
                {
                    //Bdd.getInstance().Find("fichefrais",$@"where mois={moisPrecedent}");
                    Bdd.getInstance().Update("fichefrais", "idetat", "CL", $@"mois like '{moisPrecedent}'");
                }
                if(DateTime.Now.Day >= 20)
                {
                    Bdd.getInstance().Update("fichefrais","idetat","RB",$@"idetat = 'VA' and mois like '{moisPrecedent}'");
                }
  
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

    }
}
