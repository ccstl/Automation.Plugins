﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Automation.Core;
using DotSpatial.Controls.Header;
using Automation.Plugins.YZ.Sorting.Properties;
using Automation.Plugins.YZ.Sorting.View;

namespace Automation.Plugins.YZ.Sorting.Action
{
   public class PackNoAction : AbstractAction
    {
        private const string rootKey = "kPackNoQuery";

        public override void Initialize()
        {
            DefaultSortOrder = 1;
            RootKey = rootKey;
            IsPreload = false;
        }

        public override void Activate()
        {
            this.Add(new RootItem(rootKey, "烟包查询") { SortOrder = 10001 });
            this.Add(new SimpleActionItem(rootKey, "刷新", PackNoQueryRefresh_Click) { ToolTipText = "刷新烟包查询", GroupCaption = "烟包查询", LargeImage = Resources.refresh_32x32 });
            base.Activate();
        }

        private void PackNoQueryRefresh_Click(object sender, EventArgs e)
        {
            (View as PackNoView).Refresh();
        }
    }
}