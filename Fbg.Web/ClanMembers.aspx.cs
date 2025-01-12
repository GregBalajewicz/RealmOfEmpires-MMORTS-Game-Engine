using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Fbg.Bll;
using Facebook;
using Facebook.WebControls;

public partial class ClanMembers : MyCanvasIFrameBasePage
{
 
    public class GridColumnIndes
    {
        public static int Delete = 6;
        public static int LastActive = 1;
        public static int Dismiss = 0;
        public static int Steward = 7;

    }
    private DataSet ds;
    private bool IsAuthunicated;
    string MembersPageSizeCookieName;
    public int clanID;
    // Current PageSizeIndex of Gridview


    string _listOfMembersForMessageAll = "";
    private int PageSizeIndex
    {
        get
        {
            if (Request.Cookies[MembersPageSizeCookieName] == null
                || String.IsNullOrEmpty(Request.Cookies[MembersPageSizeCookieName].ToString().Trim()))
            {
                return 0;
            }
            else
            {
                //this part to handle if the interger not well formated.
                int result;
                int.TryParse(Request.Cookies[MembersPageSizeCookieName].Value, out result);
                return result;
            }
        }
        set
        {
            Response.Cookies.Remove(MembersPageSizeCookieName);
            HttpCookie MembersPageSizeIndex = new HttpCookie(MembersPageSizeCookieName, ddlPage.SelectedIndex.ToString());
            MembersPageSizeIndex.Expires = DateTime.Now.AddYears(2);
            Response.Cookies.Add(MembersPageSizeIndex);
        }
    }
    new protected void Page_Load(object sender, EventArgs e)
    {

        base.Page_Load(sender, e);

        MasterBase_Main mainMasterPage = (MasterBase_Main)this.Master;
        mainMasterPage.Initialize(FbgPlayer, MyVillages);
        ClanMenu1.Player = FbgPlayer;
        ClanMenu1.IsMobile = isMobile;
        MembersPageSizeCookieName = FbgPlayer.Realm.ID + CONSTS.Cookies.ClanMembersPageSize;

        ClanMenu1.CurrentPage = Controls_ClanMenu.ManageClanPages.Members;

        if (!IsPostBack)
        {
            ddlPage.SelectedIndex = PageSizeIndex;
            gvw_Members.PageSize = Convert.ToInt32(ddlPage.SelectedValue);
        }
        
        PopulateClanMembers();   

    }
    private void PopulateClanMembers()
    {
        if (Request.QueryString[CONSTS.QuerryString.ClanID] != null)
        {//query string exist so its an outer clan
            int clanid;


            if (Int32.TryParse(Request.QueryString[CONSTS.QuerryString.ClanID], out clanid))//try to get clan id 
            {
                DisplayClanMembers(FbgPlayer, clanid);//get other clan info
            }
            else
            {

                GetClanInfo();
            }
        }
        else
        {

            GetClanInfo();
        }
    }
    private void GetClanInfo()
    {
        if (FbgPlayer.Clan != null)
        {
            //get my clan info
            HandleClanRoles();
            DisplayClanMembers(FbgPlayer, FbgPlayer.Clan.ID);
        }
        else
        {
             Response.Redirect("ClanOverview.aspx");
        }
    }
    private void HandleClanRoles()
    {
        # region Player Part Of Clan


        if (Request.QueryString[CONSTS.QuerryString.PlayerID] != null && Request.QueryString[CONSTS.QuerryString.RoleID] != null && Request.QueryString[CONSTS.QuerryString.Action] != null)
        {
            int pid = Convert.ToInt32(Request.QueryString[CONSTS.QuerryString.PlayerID]);
            int rid = Convert.ToInt32(Request.QueryString[CONSTS.QuerryString.RoleID]);
            int Action = Convert.ToInt32(Request.QueryString[CONSTS.QuerryString.Action]);
            # region security for Owner and Admin
            if (FbgPlayer.Role.IsPlayerPartOfRole(Role.MemberRole.Owner))
            {
                if (Action == 1)//adding the role to specific player 
                {
                    if (!Role.AddPlayerRole(FbgPlayer, pid, rid))
                    {//Faild to add the player as the role alreday exist for this player
                        lbl_Error.Visible = true;
                        lbl_Error.Text = RS("roleExists");
                    }

                }
                else
                {
                    if (!Role.RemovePlayerRole(FbgPlayer, pid, rid))
                    {
                        //Failed to delete the player as its the only Owner 
                        lbl_Error.Visible = true;
                        lbl_Error.Text = RS("clanNeedsOwner");
                    }
                }
            }
            else if (FbgPlayer.Role.IsPlayerPartOfRole(Role.MemberRole.Administrator))
            {
                if (rid == (int)Role.MemberRole.Owner)
                {
                    lbl_Error.Visible = true;
                    lbl_Error.Text = RS("onlyOwnersAppoint");
                }
                else
                {
                    if (Action == 1)//adding the role to specific player
                    {
                        if (!Role.AddPlayerRole(FbgPlayer, pid, rid))
                        {//Faild to add the player as the role alreday exist for this player
                            lbl_Error.Visible = true;
                            lbl_Error.Text = RS("roleExists");
                        }

                    }
                    else
                    {
                        if (!Role.RemovePlayerRole(FbgPlayer, pid, rid))
                        {
                            //Faild to delete the player as its the only Owner 
                            lbl_Error.Visible = true;
                            lbl_Error.Text = RS("isOnlyOwner");
                        }
                    }
                }
            }
            else
            {
                lbl_Error.Visible = true;
                lbl_Error.Text = RS("noPermission"); 

            }
            #endregion

        }
        #endregion
    }
    private void DisplayClanMembers(Fbg.Bll.Player Player, int ClanID)
    {//Security Part

        this.clanID = ClanID;
        //default
        gvw_Members.Columns[GridColumnIndes.Delete].Visible = false;
        gvw_Members.Columns[GridColumnIndes.Dismiss].Visible = false;
        gvw_Members.Columns[GridColumnIndes.LastActive].Visible = false;
        gvw_Members.Columns[GridColumnIndes.Steward].Visible = false;
        hlnk_MessageMembersTop.Visible = false;
        trAdminMsgAllMembers.Visible = false;

        if (FbgPlayer.Clan != null)
        {
            if (FbgPlayer.Clan.ID == ClanID)//player part of clan
            {
                hlnk_MessageMembersTop.Visible = trAdminMsgAllMembers.Visible = FbgPlayer.Clan.AllowMessageAllMembers(FbgPlayer.Role);
                //hlnk_MessageMembersDown.Visible = true;
                if (FbgPlayer.Role.IsPlayerPartOfRole(Role.MemberRole.Administrator) || FbgPlayer.Role.IsPlayerPartOfRole(Role.MemberRole.Owner))
                {
                    gvw_Members.Columns[GridColumnIndes.Delete].Visible = true;
                    gvw_Members.Columns[GridColumnIndes.Dismiss].Visible = true;
                    gvw_Members.Columns[GridColumnIndes.LastActive].Visible = true;
                    gvw_Members.Columns[GridColumnIndes.Steward].Visible = true;
                    IsAuthunicated = true;
                }
                else
                {
                    gvw_Members.Columns[GridColumnIndes.Delete].Visible = true;
                    gvw_Members.Columns[GridColumnIndes.Dismiss].Visible = false;
                    gvw_Members.Columns[GridColumnIndes.LastActive].Visible = false;
                    gvw_Members.Columns[GridColumnIndes.Steward].Visible = false;
                    IsAuthunicated = false;
                }

                gvw_Members.Attributes.Add("Rel", "gaMembers");
            }
            else//player is not part of clan
            {
            }
        }
        //Bind Part
        ds = Fbg.Bll.Clan.ViewClanMembers(FbgPlayer, ClanID, true);

        if (ds != null)
        {
            gvw_Members.DataSource = ds;
            gvw_Members.DataBind();

        }
        else
        {
            lbl_Error.Visible = true;
            lbl_Error.Text = RS("notMember");
        }

        if (isD2) {
            hlnk_MessageMembersDown.Attributes.Add("onClick", "window.parent.ROE.Mail.sendmail('" + _listOfMembersForMessageAll + "');");
            hlnk_MessageMembersDown.NavigateUrl = "";
        }
    }

    protected string BindRole(object DataItem)
    {
        // creating a comma deliminated list of members 
        _listOfMembersForMessageAll += ((string.IsNullOrEmpty(_listOfMembersForMessageAll) ? "" : ",") 
            + (string)DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.PlayerName));
        
        int PlayerID = (int)DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.PlayerID);
        string Roles = "";

        DataRow[] rolesDrs;
        DataTable dtRoles = ds.Tables[Fbg.Bll.Clan.CONSTS.ClanMembersTableIndex.Roles];
        foreach (Role.MemberRole val in GetSortedRoles(Enum.GetValues(typeof(Role.MemberRole))))
        {
            bool Added = false;
            rolesDrs = dtRoles.Select(Fbg.Bll.Clan.CONSTS.RolesColumnNames.PlayerID + "=" + PlayerID.ToString());

            foreach (DataRow dr in rolesDrs)
            {
                if ((int)val == (int)dr[Fbg.Bll.Clan.CONSTS.RolesColumnIndex.RoleID])
                {
                    if (IsAuthunicated)
                    {
                        //Action =0 that mean if he user click the link it will remove the Role
                        Roles += "<a class='tableaction GotRole' " + CONSTS.QuerryString.Action + " = '0' " + CONSTS.QuerryString.RoleID + "='" + Convert.ToInt32(val).ToString() + "' " + CONSTS.QuerryString.PlayerID + " = '" + PlayerID + "' href='#'>" + GetRoleName(val) + " </a>";
                        Added = true;
                        break;
                    }
                    else
                    {
                        Roles += "<span class='tableaction GotRole' >" + GetRoleName(val) + " </span>";
                        Added = true;
                        break;
                    }
                }
            }
            if (!Added)
            {
                if (IsAuthunicated)
                {
                    Roles += "<a class='tableaction MissingRole' " + CONSTS.QuerryString.Action + " = '1' " + CONSTS.QuerryString.RoleID + "='" + Convert.ToInt32(val).ToString() + "' " + CONSTS.QuerryString.PlayerID + " = '" + PlayerID + "' href='#'>" + GetRoleName(val) + "</a>   ";
                }
                else
                {
                    Roles += "<span class='tableaction MissingRole' >" + GetRoleName(val) + "</span>";
                }
            }

        }
        return Roles;

    }
    protected string GetRoleName(Role.MemberRole role)
    {
        switch (role)
        {
            case Role.MemberRole.Administrator:
                return RS("adminRole");
            case Role.MemberRole.ForumAdministrator:
                return RS("forumAdminRole");
            case Role.MemberRole.Owner:
                return RS("ownerRole");
            case Role.MemberRole.Inviter:
                return RS("inviterRole");
            case Role.MemberRole.Diplomat:
                return RS("diplomatRole");
            default:
                return role.ToString() ;
        }
    }
    protected string BindLastActive(object DataItem)
    {

        //int pid = Convert.ToInt32(DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.PlayerID));
        //return "PID: "+ pid.ToString();

        bool hasSteward = !(DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.StewardPlayerID) is DBNull);
        if (DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.LastLoginTime) == DBNull.Value)
        {
            return "<span " + (hasSteward ? "" : "style='background-color:Red ;font-weight:bold;'") + ">30d+</span>";
        }
        DateTime lastLoginTime = (DateTime)DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.LastLoginTime);

        DateTime currentTime = DateTime.Now;
        TimeSpan ts = currentTime - lastLoginTime;
        if (ts.TotalDays > 3 && ts.TotalDays < 5)
        {
            return "<span " + (hasSteward ? "" : "style='background-color:Yellow ;color:Black ;'") + ">" + Math.Round(ts.TotalDays, 1).ToString() + " d</span>";
        }
        else if (ts.TotalDays > 5)
        {
            return "<span " + (hasSteward ? "" : "style='background-color:Red ;font-weight:bold;'") + ">" + Math.Round(ts.TotalDays, 1).ToString() + " d</span>";
        }
        return Math.Round(ts.TotalDays, 1).ToString() + " d";

    }
    private Array GetSortedRoles(Array Roles)
    {     //this array hold the ids as i want to sort it so when i want to make the second item is administartor i give him id=2 
        int[] myKeys =  { 0, 3, 1, 2, 4 };
        //IComparer myComparer = new myReverserClass();
        Array.Sort(myKeys, Roles);
        return Roles;
    }
    protected void gvw_Members_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Dismiss")
        {
            GridViewRow row = (GridViewRow)((Control)e.CommandSource).Parent.Parent;
            int PlayerID = (int)gvw_Members.DataKeys[row.RowIndex][0];
            int clanId = FbgPlayer.Clan.ID;
            Fbg.Common.Clan.DissmissFromClanResult result= FbgPlayer.Clan.DismissPlayer(PlayerID);

            #region Localize Controls
            LinkButton lb = (LinkButton)row.FindControl("LinkButton1");
            lb.DataBind();
            #endregion
           
            if (result == Fbg.Common.Clan.DissmissFromClanResult.TryingToDismissLastOwner)
            {
                lbl_Error.Visible = true;
                lbl_Error.Text = RS("onlyOwnerNoDismiss");
            }
            else if (result == Fbg.Common.Clan.DissmissFromClanResult.AdminTryingToDismissOwner)
            {
                lbl_Error.Visible = true;
                lbl_Error.Text = RS("adminCannotDismiss");
            }
            else
            {
//                ChatHub2.ChatHub2.DismissClanChat(PlayerID.ToString(), clanId, FbgPlayer.Realm.ID.ToString());   //remove player from chat
                InvalidateFbgPlayerRoles();
                Response.Redirect("ClanMembers.aspx");
            }
        }
    }
  
    protected string BindPlayerName(object DataItem)
    {
        return  DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.PlayerName ).ToString ();
    }
    /*
    protected bool BindSleepMode(object DataItem)
    {
        if (FbgPlayer.Realm.SleepModeGet.IsAvailableOnThisRealm)
        {
            if (!(DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.SleepModeActiveFrom) is DBNull))
            {
                return FbgPlayer.Realm.SleepModeGet.IsPlayerInSleepMode((DateTime)DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.SleepModeActiveFrom));
            }
            
        }
        return false;
    }
    */

    //for handling VM, WM, SM
    protected dynamic BindAwayStatus(object DataItem)
    {

        //Check VM first - if realm has VM, and VM data exists
        if (FbgPlayer.Realm.VacationModeGet.Allowed &&
            !(DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.VacationModeRequestOn) is DBNull))
        {
            if (FbgPlayer.Realm.VacationModeGet.IsPlayerInVacationMode((DateTime)DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.VacationModeRequestOn))) {
                return new
                {
                    away = true,
                    icon = "https://static.realmofempires.com/images/icons/margarita.png"
                };
            }
        }

        //Check WM next - if realm has WM, and WM data exists
        if (FbgPlayer.Realm.VacationModeGet.Allowed &&
            !(DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.WeekendModetakesEffectOn) is DBNull))
        {
            if (FbgPlayer.Realm.WeekendModeGet.IsPlayerInWeekendMode((DateTime)DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.WeekendModetakesEffectOn))) {
                return new
                {
                    away = true,
                    icon = "https://static.realmofempires.com/images/icons/sunumbrella.png"
                };
            }

        }

        //Check SM third - if realm has SM, and SM data exists
        if (FbgPlayer.Realm.SleepModeGet.IsAvailableOnThisRealm &&
            !(DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.SleepModeActiveFrom) is DBNull))
        {
            if (FbgPlayer.Realm.SleepModeGet.IsPlayerInSleepMode((DateTime)DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.SleepModeActiveFrom))) {
                return new
                {
                    away = true,
                    icon = "https://static.realmofempires.com/images/misc/sleepicon.png"
                };
            }

        }

        //default non away status
        return new {
            away = false,
            icon = ""
        };
    }

    protected string BindPlayerURL(object DataItem)
    {
        if (!isMobile)
        {
            return NavigationHelper.PlayerPublicOverview((int)DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.PlayerID));
        }
        else
        {
            return ("");
        }

    }
    protected string BindSteward(object DataItem)
    {
        if (DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.StewardPlayerID) is DBNull)
        {
            return string.Empty;
        }
        else
        {
            return String.Format("<a target='_blank' href='{0}'>{1}</a>"
                , NavigationHelper.PlayerPublicOverview_NoTilda((int)DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.StewardPlayerID))
                , DataBinder.Eval(DataItem, Fbg.Bll.Clan.CONSTS.ClanMembersColName.StewardPlayerName));
        }
    }

    protected void ddlPage_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageSizeIndex = ddlPage.SelectedIndex;

        gvw_Members.PageSize = Convert.ToInt32(ddlPage.SelectedValue);
      //  gvw_Members.PageIndex = PageIndex;
        PopulateClanMembers();   
    }
    protected void gvw_Members_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvw_Members.PageIndex = e.NewPageIndex;
        PopulateClanMembers();   
    }
    protected override void OnPreInit(EventArgs e)
    {

        if (isMobile)
        {
            base.MasterPageFile = "masterMain_m.master";
        }
        else if (isD2)
        {
            base.MasterPageFile = "masterMain_d2.master";
        }
        base.OnPreInit(e);
    }

    public  string FormatNumber(long num)
    {
        if (isMobile) {
            return Utils.FormatShortNum(num);
        }
        else {
            return Utils.FormatCost(num);
        }
    }
}
