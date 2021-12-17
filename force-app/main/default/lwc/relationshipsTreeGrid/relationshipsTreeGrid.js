import { LightningElement, api, track } from "lwc";
import getInitialView from "@salesforce/apex/RelationshipsTreeGridController.getInitialView";
import getRelationships from "@salesforce/apex/RelationshipsTreeGridController.getRelationships";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import RELATIONSHIP_CONTACT from "@salesforce/schema/npe4__Relationship__c.npe4__Contact__c";
import RELATIONSHIP_OBJECT from "@salesforce/schema/npe4__Relationship__c";

import REL_View_Contact_Record from "@salesforce/label/c.REL_View_Contact_Record";
import REL_Create_New_Relationship from "@salesforce/label/c.REL_Create_New_Relationship";
import REL_RECenter from "@salesforce/label/c.REL_RECenter";


const TABLE_ACTIONS = {
    NEW_RELATIONSHIP: "new_relationship",
    RE_CENTER: "re_center",
    VIEW_RECORD: "view_record"
};

const COLUMNS_DEF = [
    {
        label: "Full Name",
        fieldName: "contactName",
        type: "text"
    },
    {
        label: "Title",
        fieldName: "title",
        type: "text"
    },
    {
        label: "Account",
        fieldName: "accountName",
        type: "text"
    },
    {
        label: "Relationship Explanation",
        fieldName: "relationshipExplanation",
        type: "text"
    },
    {
        type: "action",
        typeAttributes: {
            rowActions: [
                {
                    label: REL_View_Contact_Record,
                    name: TABLE_ACTIONS.VIEW_RECORD
                },
                {
                    label: REL_Create_New_Relationship,
                    name: TABLE_ACTIONS.NEW_RELATIONSHIP
                },
                {
                    label: REL_RECenter,
                    name: TABLE_ACTIONS.RE_CENTER
                }
            ]
        }
    }
];

export default class RelationshipsTreeGrid extends NavigationMixin(LightningElement) {
    @api recordId;
    @api isLightningOut;

    @track relationships;
    columns;
    displayedRelationshipIds = [];
    contactIdsLoaded = [];
    vfPageURL;


    async connectedCallback() {
        const relationshipsListView = await this.getInitialView(this.recordId);

        if (relationshipsListView) {

            this.columns = COLUMNS_DEF.map(column => {
                if(column.fieldName) {
                    return {
                        ...column,
                        label: relationshipsListView.labels[column.fieldName]
                    }
                }
                if(!relationshipsListView.showCreateRelationshipButton && column.type === 'action') {
                    return {
                        ...column,
                        typeAttributes: {
                            rowActions: column.typeAttributes.rowActions.filter(({name}) => name !== TABLE_ACTIONS.NEW_RELATIONSHIP)
                        }
                    }
                }
                return column;
            });

            this.vfPageURL = relationshipsListView.vfPageURL;
            this.relationships = relationshipsListView.relations.map(relationship => {
                this.displayedRelationshipIds.push(relationship.relationshipId);
                return {
                    ...relationship,
                    _children: []
                };
            });
        }
    }

    async getInitialView(contactId) {
        try {
            return await getInitialView({contactId});
        } catch (ex) {
            this.dispatchEvent(new CustomEvent('accesserror', { detail: ex.body.message }));
        }
    }

    async getRelationships(contactId) {
        try {
            return await getRelationships({contactId});
        } catch (ex) {
            this.dispatchEvent(new CustomEvent('accesserror', { detail: ex.body.message }));
        }
    }

    async handleToggle(event) {
        const { hasChildrenContent, row } = event.detail;
        if (!hasChildrenContent) {

            const relationshipViews = await this.getRelationships(row.id);

            const filteredChildren = relationshipViews.map(relationship => {
                if (this.isAlreadyLoaded(relationship.contactId)) {
                    return relationship;
                }
                return {
                    ...relationship,
                    _children: []
                };
            }).filter(relationship => {
                // to prevent circular relationships / cycles, only show each individual relationship once
                return !this.displayedRelationshipIds.includes(relationship.relationshipId);
            });

            this.relationships = this.addChildrenToRow(this.relationships, filteredChildren, row);
        }
    }

    addChildrenToRow(relationships, children, row) {
        return relationships.map(relationship => {
            if (relationship._children && relationship._children.length > 0) {
                const _children = this.addChildrenToRow(relationship._children, children, row);
                return {
                    ...relationship,
                    _children
                };
            }

            if (relationship.contactId === row.id) {
                delete relationship._children;
            }

            if (relationship.relationshipId === row.relationshipId) {
                if (children.length > 0) {
                    this.displayedRelationshipIds = this.displayedRelationshipIds.concat(children.map(child => child.relationshipId));
                    this.contactIdsLoaded.push(relationship.contactId);
                    return {
                        ...relationship,
                        _children: children
                    };
                } else {
                    delete relationship._children;
                }
            }

            return relationship;
        });
    }

    navigateToRecord(recordId) {
        if (this.isLightningOut) {
            window.open('/' + recordId);
        } else {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId,
                    actionName: "view"
                }
            });
        }
    }

    newRelationship(recordId) {

        const defaultFieldValues = encodeDefaultFieldValues({
            [RELATIONSHIP_CONTACT.fieldApiName]: recordId
        });

        const navigateArgs = {
            type: "standard__objectPage",
            attributes: {
                objectApiName: RELATIONSHIP_OBJECT.objectApiName,
                actionName: "new"
            },
            state: { defaultFieldValues }
        };

        this[NavigationMixin.Navigate](navigateArgs);
    }

    reCenterOnContact(contactId) {
        if (this.isLightningOut) {
            window.location = this.vfPageURL + "?isdtp=p1&id=" + contactId;
        } else {
            const navigateArgs = {
                type: "standard__webPage",
                attributes: {
                    url: this.vfPageURL + "?id=" + contactId
                }
            };

            this[NavigationMixin.Navigate](navigateArgs);
        }
    }

    handleRowAction(event) {
        const { action, row } = event.detail;

        switch (action.name) {
            case TABLE_ACTIONS.VIEW_RECORD:
                this.navigateToRecord(row.contactId);
                break;
            case TABLE_ACTIONS.RE_CENTER:
                this.reCenterOnContact(row.contactId);
                break;
            case TABLE_ACTIONS.NEW_RELATIONSHIP:
                this.newRelationship(row.contactId);
                break;
        }
    }

    isAlreadyLoaded(contactId) {
        return this.contactIdsLoaded.includes(contactId) || this.recordId === contactId;
    }
}